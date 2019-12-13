# Run updates in parallel if flag is set
parallel=''
if [ "$1" = "-p" ]
then
  parallel=true
fi

# yext-ce-tools update script
"$(dirname ${BASH_SOURCE[0]})/../yext-ce-tools/scripts/update.sh" $@ &
[ $parallel ] || wait

wait

# Keep this last so that updating doesn't change this script before it's finished
# ce tools
cd "$(dirname "${BASH_SOURCE[0]}")/.." && git pull && git submodule update --init --recursive
