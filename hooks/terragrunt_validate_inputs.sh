#!/usr/bin/env bash
set -eo pipefail

# globals variables
# shellcheck disable=SC2155 # No way to assign to readonly variable in separate lines
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=_common.sh
. "$SCRIPT_DIR/_common.sh"

function main {
  common::initialize "$SCRIPT_DIR"
  common::parse_cmdline "$@"
  common::export_provided_env_vars "${ENV_VARS[@]}"
  common::parse_and_export_env_vars
  # JFYI: terragrunt validate color already suppressed via PRE_COMMIT_COLOR=never

  if terragrunt_version_ge_0_78; then
    normalize_validate_args_for_modern_terragrunt
    readonly SUBCOMMAND=("hcl" "validate" "--inputs")
    readonly RUN_ALL_SUBCOMMAND=("run" "--all" "hcl" "validate" "--inputs")

    # shellcheck disable=SC2153 # False positive
    common::per_dir_hook "$HOOK_ID" "${#ARGS[@]}" "${ARGS[@]}" "${FILES[@]}"
    return
  fi

  run_legacy_validate_inputs
}

function normalize_validate_args_for_modern_terragrunt {
  local arg_idx

  for arg_idx in "${!ARGS[@]}"; do
    case "${ARGS[$arg_idx]}" in
      --terragrunt-strict-validate|--strict-validate)
        ARGS[$arg_idx]="--strict"
        ;;
    esac
  done
}

function terragrunt_version_ge_0_78 {
  local version_raw
  local version
  local major
  local minor

  version_raw=$(terragrunt --version 2>/dev/null || true)
  version=$(echo "$version_raw" | sed -E 's/.*v?([0-9]+)\.([0-9]+)\.([0-9]+).*/\1.\2.\3/')

  if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 1
  fi

  IFS=. read -r major minor _ <<< "$version"

  if ((major > 0)); then
    return 0
  fi

  if ((minor >= 78)); then
    return 0
  fi

  return 1
}

function run_legacy_validate_inputs {
  local -a unit_dirs=()
  local final_exit_code=0
  local dir_path

  while read -r dir_path; do
    if [[ -n $dir_path ]]; then
      unit_dirs+=("$dir_path")
    fi
  done < <(legacy_unit_dirs_from_files)

  if [[ ${#unit_dirs[@]} -eq 0 ]]; then
    return 0
  fi

  # preserve errexit status
  shopt -qo errexit && ERREXIT_IS_SET=true
  set +e

  for dir_path in "${unit_dirs[@]}"; do
    pushd "$dir_path" > /dev/null || continue
    terragrunt validate-inputs "${ARGS[@]}"

    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
      final_exit_code=$exit_code
    fi

    popd > /dev/null
  done

  [[ $ERREXIT_IS_SET ]] && set -e
  exit $final_exit_code
}

function legacy_unit_dirs_from_files {
  local -a unit_files=()
  local file_with_path
  local file_dir
  local file_name

  if common::is_hook_run_on_whole_repo "$HOOK_ID" "${FILES[@]}"; then
    find . -type f -name terragrunt.hcl \
      -not -path '*/.terragrunt-cache/*' \
      -not -path '*/.terraform/*' \
      | sort -u | while read -r unit_file; do
      dirname "$unit_file"
    done
    return
  fi

  for file_with_path in "${FILES[@]}"; do
    file_dir=$(dirname "$file_with_path")
    file_name=$(basename "$file_with_path")

    if [[ $file_name == terragrunt.hcl ]]; then
      unit_files+=("$file_with_path")
      continue
    fi

    while read -r unit_file; do
      if [[ -n $unit_file ]]; then
        unit_files+=("$unit_file")
      fi
    done < <(find "$file_dir" -type f -name terragrunt.hcl \
      -not -path '*/.terragrunt-cache/*' \
      -not -path '*/.terraform/*' | sort -u)
  done

  if [[ ${#unit_files[@]} -eq 0 ]]; then
    find . -type f -name terragrunt.hcl \
      -not -path '*/.terragrunt-cache/*' \
      -not -path '*/.terraform/*' \
      | sort -u | while read -r unit_file; do
      dirname "$unit_file"
    done
    return
  fi

  printf '%s\n' "${unit_files[@]}" | sort -u | while read -r unit_file; do
    dirname "$unit_file"
  done
}

#######################################################################
# Unique part of `common::per_dir_hook`. The function is executed in loop
# on each provided dir path. Run wrapped tool with specified arguments
# Arguments:
#   dir_path (string) PATH to dir relative to git repo root.
#     Can be used in error logging
#   change_dir_in_unique_part (string/false) Modifier which creates
#     possibilities to use non-common chdir strategies.
#     Availability depends on hook.
#   args (array) arguments that configure wrapped tool behavior
# Outputs:
#   If failed - print out hook checks status
#######################################################################
function per_dir_hook_unique_part {
  # shellcheck disable=SC2034 # Unused var.
  local -r dir_path="$1"
  # shellcheck disable=SC2034 # Unused var.
  local -r change_dir_in_unique_part="$2"
  shift 2
  local -a -r args=("$@")

  # pass the arguments to hook
  terragrunt "${SUBCOMMAND[@]}" "${args[@]}"

  # return exit code to common::per_dir_hook
  local exit_code=$?
  return $exit_code
}

#######################################################################
# Unique part of `common::per_dir_hook`. The function is executed one time
# in the root git repo
# Arguments:
#   args (array) arguments that configure wrapped tool behavior
#######################################################################
function run_hook_on_whole_repo {
  local -a -r args=("$@")

  # pass the arguments to hook
  terragrunt "${RUN_ALL_SUBCOMMAND[@]}" "${args[@]}"

  # return exit code to common::per_dir_hook
  local exit_code=$?
  return $exit_code
}

[ "${BASH_SOURCE[0]}" != "$0" ] || main "$@"
