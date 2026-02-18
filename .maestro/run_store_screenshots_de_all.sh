#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUNNER_SCRIPT="${SCRIPT_DIR}/run_store_screenshots_de_ios.sh"
ANDROID_RUNNER_SCRIPT="${SCRIPT_DIR}/run_store_screenshots_de_android.sh"
RUNNER_APP_PATH="${IOS_SIM_APP_PATH:-${REPO_ROOT}/build/ios/iphonesimulator/Runner.app}"

IPHONE_FLOW_FILE="${SCRIPT_DIR}/flows/store_screenshots_de_iphone6_9.yaml"
IPHONE_OUTPUT_DIR="${SCRIPT_DIR}/screenshots/de_store_iphone6_9"
IPAD_FLOW_FILE="${SCRIPT_DIR}/flows/store_screenshots_de_ipad13.yaml"
IPAD_OUTPUT_DIR="${SCRIPT_DIR}/screenshots/de_store_ipad13"
CLOSE_SIMULATOR_ON_SUCCESS="${CLOSE_SIMULATOR_ON_SUCCESS:-1}"

select_udid_from_idb() {
  local targets
  local pattern
  local udid

  command -v idb >/dev/null 2>&1 || return 1
  targets="$(idb list-targets --only simulator 2>/dev/null || true)"
  [[ -n "${targets}" ]] || return 1

  for pattern in "$@"; do
    udid="$(
      printf '%s\n' "${targets}" |
        awk -F ' \\| ' -v pattern="${pattern}" '
          BEGIN { IGNORECASE = 1 }
          $1 ~ pattern {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
            print $2
            exit
          }
        '
    )"
    if [[ -n "${udid}" ]]; then
      echo "${udid}"
      return 0
    fi
  done

  return 1
}

select_udid_from_simctl() {
  local devices
  local pattern
  local udid

  command -v xcrun >/dev/null 2>&1 || return 1
  devices="$(xcrun simctl list devices available 2>/dev/null || true)"
  [[ -n "${devices}" ]] || return 1

  for pattern in "$@"; do
    udid="$(
      printf '%s\n' "${devices}" |
        awk -F '[()]' -v pattern="${pattern}" '
          BEGIN { IGNORECASE = 1 }
          $0 ~ pattern {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
            if ($2 ~ /^[A-F0-9-]+$/) {
              print $2
              exit
            }
          }
        '
    )"
    if [[ -n "${udid}" ]]; then
      echo "${udid}"
      return 0
    fi
  done

  return 1
}

resolve_device_udid() {
  local label="$1"
  local env_var_name="$2"
  local explicit_udid="$3"
  shift 3

  local patterns=("$@")
  local detected_udid

  if [[ -n "${explicit_udid}" ]]; then
    echo "${explicit_udid}"
    return 0
  fi

  detected_udid="$(select_udid_from_idb "${patterns[@]}" || true)"
  if [[ -n "${detected_udid}" ]]; then
    echo "${detected_udid}"
    return 0
  fi

  detected_udid="$(select_udid_from_simctl "${patterns[@]}" || true)"
  if [[ -n "${detected_udid}" ]]; then
    echo "${detected_udid}"
    return 0
  fi

  echo "No suitable simulator found for ${label}." >&2
  echo "Set ${env_var_name} to a matching simulator UDID and rerun." >&2
  return 1
}

boot_simulator() {
  local udid="$1"
  xcrun simctl boot "${udid}" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "${udid}" -b
}

install_runner_app() {
  local udid="$1"
  xcrun simctl install "${udid}" "${RUNNER_APP_PATH}" >/dev/null
}

run_flow() {
  local udid="$1"
  local flow_file="$2"
  local output_dir="$3"

  MAESTRO_DEVICE_ID="${udid}" \
    MAESTRO_FLOW_FILE="${flow_file}" \
    MAESTRO_OUTPUT_DIR="${output_dir}" \
    bash "${RUNNER_SCRIPT}"
}

close_simulator_app() {
  osascript -e 'tell application "Simulator" to quit' >/dev/null 2>&1 || true
}

file_mtime_epoch() {
  local file_path="$1"

  if stat -f %m "${file_path}" >/dev/null 2>&1; then
    stat -f %m "${file_path}"
    return 0
  fi

  stat -c %Y "${file_path}"
}

validate_new_screenshots() {
  local label="$1"
  local output_dir="$2"
  local since_epoch="$3"
  shift 3

  local screenshot_name
  local screenshot_path
  local screenshot_mtime
  local has_errors=0

  for screenshot_name in "$@"; do
    screenshot_path="${output_dir}/${screenshot_name}.png"
    if [[ ! -f "${screenshot_path}" ]]; then
      echo "[${label}] Missing screenshot: ${screenshot_path}" >&2
      has_errors=1
      continue
    fi

    screenshot_mtime="$(file_mtime_epoch "${screenshot_path}" || true)"
    if [[ -z "${screenshot_mtime}" ]]; then
      echo "[${label}] Could not read timestamp: ${screenshot_path}" >&2
      has_errors=1
      continue
    fi

    if [[ "${screenshot_mtime}" -lt "${since_epoch}" ]]; then
      echo "[${label}] Stale screenshot (older than current run): ${screenshot_path}" >&2
      has_errors=1
    fi
  done

  if [[ "${has_errors}" -ne 0 ]]; then
    return 1
  fi

  return 0
}

run_and_validate_flow() {
  local label="$1"
  local udid="$2"
  local flow_file="$3"
  local output_dir="$4"
  shift 4

  local expected_shots=("$@")
  local run_started_epoch
  local flow_exit=0
  local outputs_valid=0

  mkdir -p "${output_dir}"
  run_started_epoch="$(date +%s)"

  if run_flow "${udid}" "${flow_file}" "${output_dir}"; then
    flow_exit=0
  else
    flow_exit=$?
  fi

  if validate_new_screenshots "${label}" "${output_dir}" "${run_started_epoch}" "${expected_shots[@]}"; then
    outputs_valid=1
  fi

  if [[ "${flow_exit}" -ne 0 && "${outputs_valid}" -eq 1 ]]; then
    echo "Warning: ${label} flow exited with ${flow_exit}, but screenshots were freshly generated."
  fi

  if [[ "${outputs_valid}" -eq 1 ]]; then
    echo "${label} screenshots validated."
    return 0
  fi

  echo "${label} screenshot validation failed: expected fresh outputs were not fully generated." >&2
  return 1
}

run_device_phase() {
  local label="$1"
  local udid="$2"
  local flow_file="$3"
  local output_dir="$4"
  shift 4

  local expected_shots=("$@")
  local phase_status=0

  echo "Starting ${label} run on simulator ${udid}..."
  open -a Simulator --args -CurrentDeviceUDID "${udid}" >/dev/null 2>&1 || true
  boot_simulator "${udid}"
  install_runner_app "${udid}"

  if ! run_and_validate_flow "${label}" "${udid}" "${flow_file}" "${output_dir}" "${expected_shots[@]}"; then
    phase_status=1
  fi

  if [[ "${phase_status}" -eq 0 && "${CLOSE_SIMULATOR_ON_SUCCESS}" == "1" ]]; then
    close_simulator_app
  fi

  return "${phase_status}"
}

if [[ ! -x "${RUNNER_SCRIPT}" ]]; then
  echo "Missing or non-executable runner script: ${RUNNER_SCRIPT}" >&2
  exit 1
fi

if [[ ! -f "${IPHONE_FLOW_FILE}" ]]; then
  echo "Missing flow file: ${IPHONE_FLOW_FILE}" >&2
  exit 1
fi

if [[ ! -f "${IPAD_FLOW_FILE}" ]]; then
  echo "Missing flow file: ${IPAD_FLOW_FILE}" >&2
  exit 1
fi

echo 'Building iOS simulator app...'
(
  cd "${REPO_ROOT}"
  fvm flutter build ios --simulator
)

if [[ ! -d "${RUNNER_APP_PATH}" ]]; then
  echo "Missing built app at: ${RUNNER_APP_PATH}" >&2
  exit 1
fi

declare -a IPHONE_69_PATTERNS=(
  'iPhone 17 Pro Max'
  'iPhone 16 Pro Max'
  'iPhone .*Pro Max'
)

declare -a IPAD_13_PATTERNS=(
  'iPad Pro 13-inch'
  'iPad Pro \(13-inch\)'
  'iPad Pro.*13'
  'iPad Pro.*12\.9'
)

declare -a IPHONE_EXPECTED_SHOTS=(
  '01_input'
  '02_order'
  '03_change'
  '04_edit'
  '05_product_edit'
)

declare -a IPAD_EXPECTED_SHOTS=(
  '01_input_order'
  '02_change'
  '03_edit'
  '04_product_edit'
)

IPHONE_UDID="$(
  resolve_device_udid \
    '6.9-inch iPhone simulator' \
    'MAESTRO_IPHONE_DEVICE_ID' \
    "${MAESTRO_IPHONE_DEVICE_ID:-}" \
    "${IPHONE_69_PATTERNS[@]}"
)"

IPAD_UDID="$(
  resolve_device_udid \
    '13-inch iPad simulator' \
    'MAESTRO_IPAD_DEVICE_ID' \
    "${MAESTRO_IPAD_DEVICE_ID:-}" \
    "${IPAD_13_PATTERNS[@]}"
)"

if [[ "${IPHONE_UDID}" == "${IPAD_UDID}" ]]; then
  echo "Resolved identical UDIDs (${IPHONE_UDID}) for iPhone and iPad; aborting." >&2
  exit 1
fi

echo "Using iPhone simulator: ${IPHONE_UDID}"
echo "Using iPad simulator: ${IPAD_UDID}"
status=0

if ! run_device_phase 'iPhone' "${IPHONE_UDID}" "${IPHONE_FLOW_FILE}" "${IPHONE_OUTPUT_DIR}" "${IPHONE_EXPECTED_SHOTS[@]}"; then
  status=1
fi

if ! run_device_phase 'iPad' "${IPAD_UDID}" "${IPAD_FLOW_FILE}" "${IPAD_OUTPUT_DIR}" "${IPAD_EXPECTED_SHOTS[@]}"; then
  status=1
fi

if [[ "${status}" -ne 0 ]]; then
  echo 'One or more screenshot flows failed validation.' >&2
  exit "${status}"
fi

if [[ ! -x "${ANDROID_RUNNER_SCRIPT}" ]]; then
  echo "Missing or non-executable Android runner script: ${ANDROID_RUNNER_SCRIPT}" >&2
  exit 1
fi

if ! bash "${ANDROID_RUNNER_SCRIPT}"; then
  echo 'Android screenshot flows failed.' >&2
  exit 1
fi

echo 'All iOS and Android screenshot flows completed successfully.'
