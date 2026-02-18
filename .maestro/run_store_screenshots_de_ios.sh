#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FLOW_FILE="${MAESTRO_FLOW_FILE:-${SCRIPT_DIR}/flows/store_screenshots_de_iphone6_9.yaml}"
OUTPUT_DIR="${MAESTRO_OUTPUT_DIR:-${SCRIPT_DIR}/screenshots/de_store_iphone6_9}"
JSON_SOURCE="${REPO_ROOT}/assets/de_appstore_products.json"
IMPORT_FILE_NAME='de_appstore_prod.json'
CLEANUP_IMPORTED_FILE_AFTER_RUN="${CLEANUP_IMPORTED_FILE_AFTER_RUN:-1}"
IOS_APP_ID="${IOS_APP_ID:-com.msonntag.ordermate}"
DEVICE_UDID=''
FILE_PROVIDER_DIRS=()

mkdir -p "${OUTPUT_DIR}"

if [[ "${FLOW_FILE}" != /* ]]; then
  FLOW_FILE="${REPO_ROOT}/${FLOW_FILE}"
fi

if [[ ! -f "${FLOW_FILE}" ]]; then
  echo "Missing Maestro flow: ${FLOW_FILE}" >&2
  exit 1
fi

if [[ ! -f "${JSON_SOURCE}" ]]; then
  echo "Missing source JSON: ${JSON_SOURCE}" >&2
  exit 1
fi

cleanup_import_file() {
  local script_status=$?
  local removed_count=0
  local candidate_path
  local dir

  if [[ "${CLEANUP_IMPORTED_FILE_AFTER_RUN}" != "1" ]]; then
    return "${script_status}"
  fi

  if [[ -z "${DEVICE_UDID}" || "${#FILE_PROVIDER_DIRS[@]}" -eq 0 ]]; then
    return "${script_status}"
  fi

  for dir in "${FILE_PROVIDER_DIRS[@]}"; do
    candidate_path="${dir}/${IMPORT_FILE_NAME}"
    if [[ -f "${candidate_path}" ]] && rm -f "${candidate_path}"; then
      echo "Cleaned imported JSON: ${candidate_path}"
      removed_count=$((removed_count + 1))
    fi
  done

  if [[ "${removed_count}" -eq 0 ]]; then
    echo "No imported JSON cleanup needed for simulator: ${DEVICE_UDID}"
  fi

  return "${script_status}"
}

trap cleanup_import_file EXIT

resolve_device_udid() {
  local explicit_udid="${MAESTRO_DEVICE_ID:-}"
  if [[ -n "${explicit_udid}" ]]; then
    echo "${explicit_udid}"
    return 0
  fi

  local detected_udid
  detected_udid="$(
    xcrun simctl list devices available |
      awk -F '[()]' '/iPhone 17 Pro Max/ { print $2; exit }'
  )"
  if [[ -n "${detected_udid}" ]]; then
    echo "${detected_udid}"
    return 0
  fi

  detected_udid="$(
    xcrun simctl list devices available |
      awk -F '[()]' '/iPhone (16|17) Pro Max/ { print $2; exit }'
  )"
  if [[ -n "${detected_udid}" ]]; then
    echo "${detected_udid}"
    return 0
  fi

  return 1
}

DEVICE_UDID="$(resolve_device_udid || true)"

if [[ -z "${DEVICE_UDID}" ]]; then
  echo 'No iPhone 17 Pro Max (or other Pro Max) simulator found.' >&2
  echo 'Set MAESTRO_DEVICE_ID to a 6.9-inch iPhone simulator UDID and rerun.' >&2
  exit 1
fi

open -a Simulator --args -CurrentDeviceUDID "${DEVICE_UDID}" >/dev/null 2>&1 || true
xcrun simctl boot "${DEVICE_UDID}" >/dev/null 2>&1 || true
xcrun simctl bootstatus "${DEVICE_UDID}" -b

# Ensure German locale in the simulator.
xcrun simctl spawn "${DEVICE_UDID}" defaults write -g AppleLanguages '(de)' || true
xcrun simctl spawn "${DEVICE_UDID}" defaults write -g AppleLocale de_DE || true
xcrun simctl spawn "${DEVICE_UDID}" defaults write -g AppleMeasurementUnits Metric || true
xcrun simctl spawn "${DEVICE_UDID}" killall -HUP SpringBoard >/dev/null 2>&1 || true

SIM_DATA_ROOT="${HOME}/Library/Developer/CoreSimulator/Devices/${DEVICE_UDID}/data"

# Launch Files once to ensure its storage containers are initialized.
xcrun simctl launch "${DEVICE_UDID}" com.apple.DocumentsApp >/dev/null 2>&1 || true

collect_file_provider_dirs() {
  local docs_app_data

  # 1) Files app-owned locations.
  docs_app_data="$(xcrun simctl get_app_container "${DEVICE_UDID}" com.apple.DocumentsApp data 2>/dev/null || true)"
  if [[ -n "${docs_app_data}" ]]; then
    echo "${docs_app_data}/Library/File Provider Storage"
    echo "${docs_app_data}/Documents"
  fi

  # 2) Known File Provider storage locations.
  find "${SIM_DATA_ROOT}/Containers/Shared/AppGroup" \
    -maxdepth 4 \
    -type d \
    -name 'File Provider Storage' \
    2>/dev/null || true

  find "${SIM_DATA_ROOT}/Containers/Data/Application" \
    -maxdepth 6 \
    -type d \
    -name 'File Provider Storage' \
    2>/dev/null || true
}

while IFS= read -r dir; do
  [[ -n "${dir}" ]] || continue
  FILE_PROVIDER_DIRS+=("${dir}")
done < <(collect_file_provider_dirs | awk 'NF && !seen[$0]++')

if [[ "${#FILE_PROVIDER_DIRS[@]}" -eq 0 ]]; then
  echo "Could not locate a writable Files storage directory for simulator ${DEVICE_UDID}." >&2
  echo "Checked under: ${SIM_DATA_ROOT}" >&2
  echo 'Try opening the Files app manually once and rerun.' >&2
  exit 1
fi

pick_newest_path() {
  local selected=''
  local selected_mtime=0
  local path
  local mtime

  for path in "$@"; do
    [[ -d "${path}" ]] || continue
    mtime="$(stat -f %m "${path}" 2>/dev/null || echo 0)"
    if [[ "${mtime}" -gt "${selected_mtime}" ]]; then
      selected="${path}"
      selected_mtime="${mtime}"
    fi
  done

  [[ -n "${selected}" ]] && echo "${selected}"
}

SHARED_GROUP_DIRS=()
for dir in "${FILE_PROVIDER_DIRS[@]}"; do
  if [[ "${dir}" == *"/Containers/Shared/AppGroup/"*"/File Provider Storage" ]]; then
    SHARED_GROUP_DIRS+=("${dir}")
  fi
done

PRIMARY_DIR="$(pick_newest_path "${SHARED_GROUP_DIRS[@]}")"
if [[ -z "${PRIMARY_DIR}" ]]; then
  PRIMARY_DIR="${FILE_PROVIDER_DIRS[0]}"
fi

mkdir -p "${PRIMARY_DIR}" || true
if [[ ! -d "${PRIMARY_DIR}" ]]; then
  echo "Primary Files directory is not writable: ${PRIMARY_DIR}" >&2
  exit 1
fi

copied_path=''
if cp "${JSON_SOURCE}" "${PRIMARY_DIR}/${IMPORT_FILE_NAME}" && [[ -f "${PRIMARY_DIR}/${IMPORT_FILE_NAME}" ]]; then
  copied_path="${PRIMARY_DIR}/${IMPORT_FILE_NAME}"
fi

if [[ -z "${copied_path}" ]]; then
  echo "Could not copy JSON into any detected Files storage directory for ${DEVICE_UDID}." >&2
  exit 1
fi

# Seed other candidates quietly as a fallback for simulator/runtime differences.
for dir in "${FILE_PROVIDER_DIRS[@]}"; do
  [[ "${dir}" == "${PRIMARY_DIR}" ]] && continue
  mkdir -p "${dir}" >/dev/null 2>&1 || true
  cp "${JSON_SOURCE}" "${dir}/${IMPORT_FILE_NAME}" >/dev/null 2>&1 || true
done

echo "Copied JSON to: ${copied_path}"
echo "Prepared simulator: ${DEVICE_UDID}"

(
  cd "${OUTPUT_DIR}"
  MAESTRO_SUBFLOW_APP_ID="${IOS_APP_ID}" maestro test "${FLOW_FILE}" --device "${DEVICE_UDID}"
)

echo "Screenshots saved to: ${OUTPUT_DIR}"
