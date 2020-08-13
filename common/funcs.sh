hash() {
  echo $(( 16#$(md5 <<< "$1") )) | tr -d '-'
}

readJSON() {
  local json="$1"
  local accessPath="$2"

  echo "$json" | python -c "import json, sys; print(json.load(sys.stdin)${accessPath})"
}

trash() {
  "$(dirname "${BASH_SOURCE[0]}")/../scripts/trash.sh" $@
}
