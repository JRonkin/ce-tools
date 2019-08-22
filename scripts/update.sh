# Run updates in parallel if flag is set
parallel=''
if [ "$1" = "-p" ]
then
  parallel=true
fi

# generator ysp
cd ~/repo/generator-ysp && git co master && git pull && yarn install && yarn link &
[ $parallel ] || wait

# pages builder
cd ~/repo/pages-builder && git pull &
[ $parallel ] || wait

# pages tools
cd ~/repo/pages-tools && git pull &
[ $parallel ] || wait

# Homebrew
brew upgrade &
[ $parallel ] || wait

# npm
npm i -g npm bower yo &
[ $parallel ] || wait

# Python
(
  pip install --upgrade pip --user
  pip install --upgrade awscli --user
) &
[ $parallel ] || wait

# alpha and congo
(
  cd $ALPHA && git co master && git pull && make

  cd $YEXT && git co master && git pull && glock sync yext && (make || make binaries || (
    # make failed, build all packages individually
    while read package
    do
      go install -v "$(dirname "$package")"
    done <<< "$(find . -name main.go -type f)"
  ))

  cd $CONGO && git co master && git pull && glock sync congo && (make || (
    # make failed, build all packages individually
    while read package
    do
      go install -v "$(dirname "$package")"
    done <<< "$(find . -name main.go -type f | grep -v ./client)"
  ))
  cd $ALPHA && git co master
) &
[ $parallel ] || wait



# Keep this last so that updating doesn't change this script before it's finished
# ce tools
cd ~/repo/ce-tools && git pull &
wait
