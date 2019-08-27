hash() {
  cksum <<< "$1" | cut -d ' ' -f 1
}

trash() {
  "$(dirname "${BASH_SOURCE[0]}")/../scripts/trash.sh" $@
}
