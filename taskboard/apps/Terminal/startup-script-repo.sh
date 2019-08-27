# This script runs when Terminal opens a new window and there is an active repo.
# Current folder is [ITEMS_DIR]/[JIRANUM]/[REPO]

if [ -d src ]
then
  cd src

  "$(realpath "$(dirname "${BASH_SOURCE[0]}")/../../..")/scripts/repo-fixes.sh"

  [ -f package.json ] && yarn install
  [ -f bower.json ] && bower install
  [ -f Gemfile ] && bundle install
fi
