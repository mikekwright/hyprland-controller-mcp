#!/usr/bin/env sh

set -eu

die() {
  printf '%s\n' "$1" >&2
  exit 1
}

cleanup() {
  if [ -n "${spec_tmp_dir:-}" ] && [ -d "$spec_tmp_dir" ]; then
    rm -rf "$spec_tmp_dir"
  fi

  if [ -n "${scenario_tmp_dir:-}" ] && [ -d "$scenario_tmp_dir" ]; then
    rm -rf "$scenario_tmp_dir"
  fi
}

trim_hyphens() {
  value=$1

  while [ "${value#-}" != "$value" ]; do
    value=${value#-}
  done

  while [ "${value%-}" != "$value" ]; do
    value=${value%-}
  done

  printf '%s' "$value"
}

if [ "$#" -eq 0 ]; then
  die "Feature name is required. Usage: scripts/create-spec.sh \"Feature Name\""
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)

spec_template_dir="$repo_root/specs/_templates"
scenario_template_dir="$repo_root/scenarios/_templates"
specs_dir="$repo_root/specs"
scenario_definitions_dir="$repo_root/scenarios/definitions"

[ -d "$spec_template_dir" ] || die "Spec template directory not found: $spec_template_dir"
[ -d "$scenario_template_dir" ] || die "Scenario template directory not found: $scenario_template_dir"
[ -d "$specs_dir" ] || die "Specs directory not found: $specs_dir"
[ -d "$scenario_definitions_dir" ] || die "Scenario definitions directory not found: $scenario_definitions_dir"

feature_name=$*
slug=$(printf '%s' "$feature_name" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' '-')
slug=$(trim_hyphens "$slug")

[ -n "$slug" ] || die "Feature name produced an empty slug. Provide a name with letters or numbers."

current_date=$(date '+%Y-%m-%d')

case "$current_date" in
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
  *) die "Generated date is invalid: $current_date" ;;
esac

identifier="${current_date}_${slug}"
spec_destination="$specs_dir/$identifier"
scenario_destination="$scenario_definitions_dir/$identifier"

if [ -e "$spec_destination" ]; then
  die "Spec destination already exists: $spec_destination"
fi

if [ -e "$scenario_destination" ]; then
  die "Scenario destination already exists: $scenario_destination"
fi

spec_tmp_dir=$(mktemp -d "$specs_dir/.${identifier}.spec.XXXXXX")
scenario_tmp_dir=$(mktemp -d "$scenario_definitions_dir/.${identifier}.scenario.XXXXXX")
trap cleanup EXIT HUP INT TERM

cp -R "$spec_template_dir/." "$spec_tmp_dir"
cp -R "$scenario_template_dir/." "$scenario_tmp_dir"

mv "$spec_tmp_dir" "$spec_destination"
spec_tmp_dir=

if ! mv "$scenario_tmp_dir" "$scenario_destination"; then
  rm -rf "$spec_destination"
  die "Failed to create scenario destination: $scenario_destination"
fi

scenario_tmp_dir=
trap - EXIT HUP INT TERM

printf 'Created %s\n' "$spec_destination"
printf 'Created %s\n' "$scenario_destination"
