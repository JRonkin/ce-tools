# This script runs when Terminal opens a new window.
# Current folder is [ITEMS_DIR]/[JIRANUM]/[REPO], or [ITEMS_DIR]/[JIRANUM] if no repo

if [ -d src ]
then
  cd src
  $(dirname "${BASH_SOURCE[0]}")/../../../scripts/repo-fixes.sh

  [ -f package.json ] && yarn install
  [ -f bower.json ] && bower install
  [ -f Gemfile ] && bundle install
fi
