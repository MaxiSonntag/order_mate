#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

APP_ID="${ANDROID_APP_ID:-de.msonntag.ordermate}"
JSON_SOURCE="${REPO_ROOT}/assets/de_appstore_products.json"
IMPORT_FILE_NAME="${ANDROID_IMPORT_FILE_NAME:-de_appstore_prod.json}"
IMPORT_DEST_PATH="/sdcard/Download/${IMPORT_FILE_NAME}"

PHONE_FLOW_FILE="${ANDROID_PHONE_FLOW_FILE:-${SCRIPT_DIR}/flows/store_screenshots_de_android_phone.yaml}"
TABLET7_FLOW_FILE="${ANDROID_TABLET7_FLOW_FILE:-${SCRIPT_DIR}/flows/store_screenshots_de_android_tablet.yaml}"
TABLET10_FLOW_FILE="${ANDROID_TABLET10_FLOW_FILE:-${SCRIPT_DIR}/flows/store_screenshots_de_android_tablet.yaml}"

PHONE_OUTPUT_DIR="${ANDROID_PHONE_OUTPUT_DIR:-${SCRIPT_DIR}/screenshots/de_store_android_phone}"
TABLET7_OUTPUT_DIR="${ANDROID_TABLET7_OUTPUT_DIR:-${SCRIPT_DIR}/screenshots/de_store_android_tablet7}"
TABLET10_OUTPUT_DIR="${ANDROID_TABLET10_OUTPUT_DIR:-${SCRIPT_DIR}/screenshots/de_store_android_tablet10}"

PHONE_AVD_NAME="${ANDROID_PHONE_AVD_NAME:-OrderMate_Phone}"
TABLET7_AVD_NAME="${ANDROID_TABLET7_AVD_NAME:-OrderMate_Tablet_7in}"
TABLET10_AVD_NAME="${ANDROID_TABLET10_AVD_NAME:-OrderMate_Tablet_10in}"

PHONE_DEVICE_PROFILE="${ANDROID_PHONE_DEVICE_PROFILE:-pixel_9}"
TABLET7_DEVICE_PROFILE="${ANDROID_TABLET7_DEVICE_PROFILE:-Nexus 7 2013}"
TABLET10_DEVICE_PROFILE="${ANDROID_TABLET10_DEVICE_PROFILE:-Nexus 10}"

PHONE_PORT="${ANDROID_PHONE_EMULATOR_PORT:-5554}"
TABLET7_PORT="${ANDROID_TABLET7_EMULATOR_PORT:-5556}"
TABLET10_PORT="${ANDROID_TABLET10_EMULATOR_PORT:-5558}"

ANDROID_BUILD_MODE="${ANDROID_BUILD_MODE:-debug}"
ANDROID_SYSTEM_IMAGE_PACKAGE="${ANDROID_SYSTEM_IMAGE_PACKAGE:-system-images;android-36;google_apis_playstore;arm64-v8a}"
ANDROID_LOCALE="${ANDROID_LOCALE:-de-DE}"
ANDROID_LOCALE_LANGUAGE_EXPECTED="${ANDROID_LOCALE_LANGUAGE_EXPECTED:-de}"
ANDROID_LOCALE_COUNTRY_EXPECTED="${ANDROID_LOCALE_COUNTRY_EXPECTED:-DE}"
ANDROID_DEVICE_FILTER="${ANDROID_DEVICE_FILTER:-all}"
ANDROID_TABLET7_PORTRAIT_ROTATION="${ANDROID_TABLET7_PORTRAIT_ROTATION:-0}"
ANDROID_TABLET10_PORTRAIT_ROTATION="${ANDROID_TABLET10_PORTRAIT_ROTATION:-1}"

ADB_BIN="${ANDROID_ADB_BIN:-$(command -v adb || true)}"
MAESTRO_BIN="${MAESTRO_BIN:-$(command -v maestro || true)}"

if [[ -z "${ADB_BIN}" ]]; then
  echo 'adb is required but was not found in PATH.' >&2
  exit 1
fi

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$(cd "$(dirname "${ADB_BIN}")/.." && pwd)}"
AVDMANAGER_BIN="${ANDROID_AVDMANAGER_BIN:-${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/avdmanager}"
SDKMANAGER_BIN="${ANDROID_SDKMANAGER_BIN:-${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager}"
DEFAULT_EMULATOR_BIN="${ANDROID_SDK_ROOT}/emulator/emulator"
if [[ -n "${ANDROID_EMULATOR_BIN:-}" ]]; then
  EMULATOR_BIN="${ANDROID_EMULATOR_BIN}"
elif [[ -x "${DEFAULT_EMULATOR_BIN}" ]]; then
  EMULATOR_BIN="${DEFAULT_EMULATOR_BIN}"
else
  EMULATOR_BIN="$(command -v emulator || true)"
fi

if [[ -z "${MAESTRO_BIN}" ]]; then
  echo 'maestro CLI is required but was not found in PATH.' >&2
  exit 1
fi

if [[ ! -x "${EMULATOR_BIN}" ]]; then
  echo "Android emulator binary not found or not executable: ${EMULATOR_BIN}" >&2
  exit 1
fi

require_file() {
  local file_path="$1"
  if [[ ! -f "${file_path}" ]]; then
    echo "Missing required file: ${file_path}" >&2
    exit 1
  fi
}

normalize_device_filter() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]'
}

ANDROID_DEVICE_FILTER="$(normalize_device_filter "${ANDROID_DEVICE_FILTER}")"

validate_device_filter() {
  case "${ANDROID_DEVICE_FILTER}" in
    all|phone|tablet7|tablet10) ;;
    *)
      echo "Unsupported ANDROID_DEVICE_FILTER='${ANDROID_DEVICE_FILTER}'." >&2
      echo "Supported values: all, phone, tablet7, tablet10" >&2
      exit 1
      ;;
  esac
}

should_run_device() {
  local device_key="$1"
  [[ "${ANDROID_DEVICE_FILTER}" == 'all' || "${ANDROID_DEVICE_FILTER}" == "${device_key}" ]]
}

validate_device_filter

require_file "${JSON_SOURCE}"
if should_run_device 'phone'; then
  require_file "${PHONE_FLOW_FILE}"
fi
if should_run_device 'tablet7'; then
  require_file "${TABLET7_FLOW_FILE}"
fi
if should_run_device 'tablet10'; then
  require_file "${TABLET10_FLOW_FILE}"
fi

if [[ ! -x "${AVDMANAGER_BIN}" ]]; then
  echo "avdmanager not found or not executable: ${AVDMANAGER_BIN}" >&2
  exit 1
fi

if [[ ! -x "${SDKMANAGER_BIN}" ]]; then
  echo "sdkmanager not found or not executable: ${SDKMANAGER_BIN}" >&2
  exit 1
fi

echo "Using Android emulator binary: ${EMULATOR_BIN}"
echo "Target Android locale: ${ANDROID_LOCALE} (language=${ANDROID_LOCALE_LANGUAGE_EXPECTED}, country=${ANDROID_LOCALE_COUNTRY_EXPECTED})"
echo "Android device filter: ${ANDROID_DEVICE_FILTER}"

resolve_apk_path() {
  if [[ -n "${ANDROID_APK_PATH:-}" ]]; then
    echo "${ANDROID_APK_PATH}"
    return 0
  fi

  case "${ANDROID_BUILD_MODE}" in
    debug) echo "${REPO_ROOT}/build/app/outputs/flutter-apk/app-debug.apk" ;;
    profile) echo "${REPO_ROOT}/build/app/outputs/flutter-apk/app-profile.apk" ;;
    release) echo "${REPO_ROOT}/build/app/outputs/flutter-apk/app-release.apk" ;;
    *)
      echo "Unsupported ANDROID_BUILD_MODE: ${ANDROID_BUILD_MODE}" >&2
      exit 1
      ;;
  esac
}

APK_PATH="$(resolve_apk_path)"
SYSTEM_IMAGE_CHECKED=0

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

  [[ "${has_errors}" -eq 0 ]]
}

ensure_system_image_installed() {
  if [[ "${SYSTEM_IMAGE_CHECKED}" -eq 1 ]]; then
    return 0
  fi

  if "${SDKMANAGER_BIN}" --list_installed | grep -Fq "${ANDROID_SYSTEM_IMAGE_PACKAGE}"; then
    SYSTEM_IMAGE_CHECKED=1
    return 0
  fi

  echo "Installing missing Android system image: ${ANDROID_SYSTEM_IMAGE_PACKAGE}"
  yes | "${SDKMANAGER_BIN}" "${ANDROID_SYSTEM_IMAGE_PACKAGE}"
  SYSTEM_IMAGE_CHECKED=1
}

avd_exists() {
  local avd_name="$1"
  "${EMULATOR_BIN}" -list-avds | grep -Fxq "${avd_name}"
}

ensure_avd_exists() {
  local avd_name="$1"
  local device_profile="$2"

  if avd_exists "${avd_name}"; then
    echo "Using existing AVD: ${avd_name}"
    return 0
  fi

  ensure_system_image_installed
  echo "Creating AVD ${avd_name} with profile '${device_profile}'..."
  echo 'no' | "${AVDMANAGER_BIN}" create avd \
    --force \
    --name "${avd_name}" \
    --package "${ANDROID_SYSTEM_IMAGE_PACKAGE}" \
    --device "${device_profile}" >/dev/null
}

wait_for_android_boot() {
  local serial="$1"
  local emulator_pid="$2"
  local log_file="$3"
  local boot_completed=''
  local attempt
  local serial_online=0

  "${ADB_BIN}" start-server >/dev/null 2>&1 || true

  for attempt in $(seq 1 120); do
    if ! kill -0 "${emulator_pid}" >/dev/null 2>&1; then
      echo "Emulator process exited before ${serial} appeared in adb." >&2
      if [[ -f "${log_file}" ]]; then
        echo "Last emulator log lines (${log_file}):" >&2
        tail -n 80 "${log_file}" >&2 || true
      fi
      return 1
    fi

    if "${ADB_BIN}" devices | awk 'NR>1 {print $1}' | grep -Fxq "${serial}"; then
      serial_online=1
      break
    fi
    sleep 2
  done

  if [[ "${serial_online}" -ne 1 ]]; then
    echo "Timed out waiting for emulator ${serial} to appear in adb devices." >&2
    return 1
  fi

  for attempt in $(seq 1 180); do
    if ! kill -0 "${emulator_pid}" >/dev/null 2>&1; then
      echo "Emulator process exited before ${serial} completed boot." >&2
      if [[ -f "${log_file}" ]]; then
        echo "Last emulator log lines (${log_file}):" >&2
        tail -n 80 "${log_file}" >&2 || true
      fi
      return 1
    fi

    boot_completed="$("${ADB_BIN}" -s "${serial}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
    if [[ "${boot_completed}" == "1" ]]; then
      break
    fi
    sleep 2
  done

  if [[ "${boot_completed}" != "1" ]]; then
    echo "Timed out waiting for emulator ${serial} to boot." >&2
    return 1
  fi

  "${ADB_BIN}" -s "${serial}" shell input keyevent 82 >/dev/null 2>&1 || true
  "${ADB_BIN}" -s "${serial}" shell settings put global window_animation_scale 0 >/dev/null 2>&1 || true
  "${ADB_BIN}" -s "${serial}" shell settings put global transition_animation_scale 0 >/dev/null 2>&1 || true
  "${ADB_BIN}" -s "${serial}" shell settings put global animator_duration_scale 0 >/dev/null 2>&1 || true
}

launch_emulator() {
  local avd_name="$1"
  local port="$2"
  local serial="emulator-${port}"
  local log_file="/tmp/ordermate_${avd_name}_${port}.log"
  local emulator_pid=''

  "${ADB_BIN}" -s "${serial}" emu kill >/dev/null 2>&1 || true

  "${EMULATOR_BIN}" \
    -avd "${avd_name}" \
    -port "${port}" \
    -change-locale "${ANDROID_LOCALE}" \
    -no-boot-anim \
    -no-snapshot-save \
    -no-audio \
    -netdelay none \
    -netspeed full \
    >"${log_file}" 2>&1 &
  emulator_pid=$!

  wait_for_android_boot "${serial}" "${emulator_pid}" "${log_file}"
  echo "${serial}"
}

normalize_locale() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | tr '_' '-'
}

verify_emulator_locale() {
  local label="$1"
  local serial="$2"
  local log_file="$3"
  local locale=''
  local language=''
  local country=''
  local normalized_locale=''
  local expected_locale=''
  local expected_language=''
  local expected_country=''

  locale="$("${ADB_BIN}" -s "${serial}" shell getprop persist.sys.locale 2>/dev/null | tr -d '\r')"
  language="$("${ADB_BIN}" -s "${serial}" shell getprop persist.sys.language 2>/dev/null | tr -d '\r')"
  country="$("${ADB_BIN}" -s "${serial}" shell getprop persist.sys.country 2>/dev/null | tr -d '\r')"

  normalized_locale="$(normalize_locale "${locale}")"
  expected_locale="$(normalize_locale "${ANDROID_LOCALE}")"
  expected_language="$(echo "${ANDROID_LOCALE_LANGUAGE_EXPECTED}" | tr '[:upper:]' '[:lower:]')"
  expected_country="$(echo "${ANDROID_LOCALE_COUNTRY_EXPECTED}" | tr '[:lower:]' '[:upper:]')"

  if [[ "${normalized_locale}" == "${expected_locale}" || "${normalized_locale}" == "${expected_locale}-"* ]]; then
    echo "[${label}] Locale verified via persist.sys.locale=${locale}"
    return 0
  fi

  if [[ -z "${language}" && -z "${country}" ]]; then
    locale="$("${ADB_BIN}" -s "${serial}" shell getprop ro.product.locale 2>/dev/null | tr -d '\r')"
    normalized_locale="$(normalize_locale "${locale}")"
    if [[ "${normalized_locale}" == "${expected_locale}" || "${normalized_locale}" == "${expected_locale}-"* ]]; then
      echo "[${label}] Locale verified via ro.product.locale=${locale}"
      return 0
    fi
  fi

  if [[ "$(echo "${language}" | tr '[:upper:]' '[:lower:]')" == "${expected_language}" && "$(echo "${country}" | tr '[:lower:]' '[:upper:]')" == "${expected_country}" ]]; then
    echo "[${label}] Locale verified via persist.sys.language=${language}, persist.sys.country=${country}"
    return 0
  fi

  echo "[${label}] Locale check failed. Expected ${ANDROID_LOCALE} (language=${ANDROID_LOCALE_LANGUAGE_EXPECTED}, country=${ANDROID_LOCALE_COUNTRY_EXPECTED}), got persist.sys.locale='${locale}', persist.sys.language='${language}', persist.sys.country='${country}'." >&2
  echo "[${label}] Emulator log: ${log_file}" >&2
  if [[ -f "${log_file}" ]]; then
    tail -n 80 "${log_file}" >&2 || true
  fi
  return 1
}

configure_device_orientation() {
  local label="$1"
  local serial="$2"
  local orientation="$3"
  local portrait_rotation="${4:-0}"
  local user_rotation=''
  local attempt

  case "${orientation}" in
    auto)
      return 0
      ;;
    portrait)
      if [[ ! "${portrait_rotation}" =~ ^[0-3]$ ]]; then
        echo "[${label}] Invalid portrait rotation '${portrait_rotation}'. Expected 0,1,2,3." >&2
        return 1
      fi

      # Disable auto-rotate and force portrait with device-specific rotation.
      # Some tablet AVD profiles have landscape natural orientation.
      for attempt in 1 2 3; do
        "${ADB_BIN}" -s "${serial}" shell settings put system accelerometer_rotation 0 >/dev/null 2>&1 || true
        "${ADB_BIN}" -s "${serial}" shell settings put system user_rotation "${portrait_rotation}" >/dev/null 2>&1 || true
        "${ADB_BIN}" -s "${serial}" shell wm user-rotation lock "${portrait_rotation}" >/dev/null 2>&1 || true
        sleep 1

        user_rotation="$("${ADB_BIN}" -s "${serial}" shell settings get system user_rotation 2>/dev/null | tr -d '\r' | tr -d '[:space:]')"
        if [[ "${user_rotation}" == "${portrait_rotation}" ]]; then
          echo "[${label}] Orientation locked to portrait (user_rotation=${user_rotation}, attempt=${attempt})."
          return 0
        fi
      done

      echo "[${label}] Failed to enforce portrait mode. Expected user_rotation=${portrait_rotation}, got '${user_rotation}'." >&2
      return 1
      ;;
    portrait-0|portrait-1|portrait-2|portrait-3)
      portrait_rotation="${orientation#portrait-}"
      configure_device_orientation "${label}" "${serial}" 'portrait' "${portrait_rotation}"
      return $?
      ;;
    *)
      echo "[${label}] Unsupported orientation mode: ${orientation}" >&2
      return 1
      ;;
  esac
}

close_emulator() {
  local serial="$1"
  "${ADB_BIN}" -s "${serial}" emu kill >/dev/null 2>&1 || true
}

install_apk() {
  local serial="$1"

  if "${ADB_BIN}" -s "${serial}" install -r -t "${APK_PATH}" >/dev/null 2>&1; then
    return 0
  fi

  "${ADB_BIN}" -s "${serial}" uninstall "${APP_ID}" >/dev/null 2>&1 || true
  "${ADB_BIN}" -s "${serial}" install -r -t "${APK_PATH}" >/dev/null
}

push_import_json() {
  local serial="$1"

  "${ADB_BIN}" -s "${serial}" shell mkdir -p /sdcard/Download >/dev/null 2>&1 || true
  "${ADB_BIN}" -s "${serial}" push "${JSON_SOURCE}" "${IMPORT_DEST_PATH}" >/dev/null
  echo "Copied JSON to: ${IMPORT_DEST_PATH} (${serial})"
}

cleanup_user_data() {
  local serial="$1"

  "${ADB_BIN}" -s "${serial}" shell rm -f "${IMPORT_DEST_PATH}" >/dev/null 2>&1 || true
  "${ADB_BIN}" -s "${serial}" shell rm -f "/sdcard/Documents/${IMPORT_FILE_NAME}" >/dev/null 2>&1 || true
  "${ADB_BIN}" -s "${serial}" shell pm clear "${APP_ID}" >/dev/null 2>&1 || true
}

run_flow_and_validate() {
  local label="$1"
  local serial="$2"
  local flow_file="$3"
  local output_dir="$4"
  shift 4

  local expected_shots=("$@")
  local run_started_epoch
  local flow_exit=0
  local outputs_valid=0

  mkdir -p "${output_dir}"
  run_started_epoch="$(date +%s)"

  if (
    cd "${output_dir}"
    MAESTRO_SUBFLOW_APP_ID="${APP_ID}" "${MAESTRO_BIN}" test "${flow_file}" --device "${serial}"
  ); then
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
  local avd_name="$2"
  local device_profile="$3"
  local port="$4"
  local flow_file="$5"
  local output_dir="$6"
  local orientation_mode="$7"
  local orientation_rotation="${8:-0}"
  shift 8

  local expected_shots=("$@")
  local serial=''
  local phase_status=0
  local log_file="/tmp/ordermate_${avd_name}_${port}.log"

  ensure_avd_exists "${avd_name}" "${device_profile}"
  echo "Starting ${label} run on Android AVD ${avd_name} (port ${port})..."

  serial="$(launch_emulator "${avd_name}" "${port}")"
  if ! verify_emulator_locale "${label}" "${serial}" "${log_file}"; then
    close_emulator "${serial}"
    return 1
  fi
  if ! configure_device_orientation "${label}" "${serial}" "${orientation_mode}" "${orientation_rotation}"; then
    close_emulator "${serial}"
    return 1
  fi

  install_apk "${serial}"
  push_import_json "${serial}"

  if ! run_flow_and_validate "${label}" "${serial}" "${flow_file}" "${output_dir}" "${expected_shots[@]}"; then
    phase_status=1
  fi

  cleanup_user_data "${serial}"
  close_emulator "${serial}"

  return "${phase_status}"
}

echo "Building Android APK (${ANDROID_BUILD_MODE})..."
(
  cd "${REPO_ROOT}"
  fvm flutter build apk "--${ANDROID_BUILD_MODE}"
)

if [[ ! -f "${APK_PATH}" ]]; then
  echo "Missing built APK at: ${APK_PATH}" >&2
  exit 1
fi

declare -a PHONE_EXPECTED_SHOTS=(
  '01_input'
  '02_order'
  '03_change'
  '04_edit'
  '05_product_edit'
)

declare -a TABLET_EXPECTED_SHOTS=(
  '01_input_order'
  '02_change'
  '03_edit'
  '04_product_edit'
)

status=0

if should_run_device 'phone'; then
  if ! run_device_phase \
    'Android Phone' \
    "${PHONE_AVD_NAME}" \
    "${PHONE_DEVICE_PROFILE}" \
    "${PHONE_PORT}" \
    "${PHONE_FLOW_FILE}" \
    "${PHONE_OUTPUT_DIR}" \
    'auto' \
    '0' \
    "${PHONE_EXPECTED_SHOTS[@]}"; then
    status=1
  fi
fi

if should_run_device 'tablet7'; then
  if ! run_device_phase \
    'Android 7-inch Tablet' \
    "${TABLET7_AVD_NAME}" \
    "${TABLET7_DEVICE_PROFILE}" \
    "${TABLET7_PORT}" \
    "${TABLET7_FLOW_FILE}" \
    "${TABLET7_OUTPUT_DIR}" \
    'portrait' \
    "${ANDROID_TABLET7_PORTRAIT_ROTATION}" \
    "${TABLET_EXPECTED_SHOTS[@]}"; then
    status=1
  fi
fi

if should_run_device 'tablet10'; then
  if ! run_device_phase \
    'Android 10-inch Tablet' \
    "${TABLET10_AVD_NAME}" \
    "${TABLET10_DEVICE_PROFILE}" \
    "${TABLET10_PORT}" \
    "${TABLET10_FLOW_FILE}" \
    "${TABLET10_OUTPUT_DIR}" \
    'portrait' \
    "${ANDROID_TABLET10_PORTRAIT_ROTATION}" \
    "${TABLET_EXPECTED_SHOTS[@]}"; then
    status=1
  fi
fi

if [[ "${status}" -ne 0 ]]; then
  echo 'One or more Android screenshot flows failed validation.' >&2
  exit "${status}"
fi

echo 'All Android screenshot flows completed successfully.'
