# Run updates in parallel if flag is set
parallel=''
if [ "$1" = "-p" ]
then
	parallel=true
fi

# alpha and congo
(
	cd $YEXT && git co master && git pull && glock sync yext && make
	cd $CONGO && git co master && git pull && glock sync congo && glock sync yext && make
	cd $ALPHA && git co master && git pull && make
) &
if ! [ "$parallel" ]; then wait; fi

# generator ysp
cd ~/repo/generator-ysp && git co master && git pull && yarn install && yarn link &
if ! [ "$parallel" ]; then wait; fi

# pages builder
cd ~/repo/pages-builder && git pull &
if ! [ "$parallel" ]; then wait; fi

# pages tools
cd ~/repo/pages-tools && git pull &
if ! [ "$parallel" ]; then wait; fi

# Homebrew
brew upgrade &
if ! [ "$parallel" ]; then wait; fi

# npm
(
	npm i -g npm 
	npm i -g bower
	npm install -g yo
) &
if ! [ "$parallel" ]; then wait; fi

# Python
(
	pip install --upgrade pip --user
	pip install --upgrade awscli --user
) &
if ! [ "$parallel" ]; then wait; fi



# Keep this last so that updating doesn't change this script before it's finished
# yext ce tools
cd ~/repo/yext-ce-tools && git pull &
wait
