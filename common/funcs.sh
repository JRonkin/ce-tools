hash() {
  cksum <<< "$1" | cut -d ' ' -f 1
}

readJSON() {
  local json="$1"
  local accessPath="$2"

  echo "$json" | python -c "import json, sys; print(json.load(sys.stdin)${accessPath})"
}

trash() {
  "$(dirname "${BASH_SOURCE[0]}")/../scripts/trash.sh" $@
}
