(
	cd $YEXT && git co master && git pull && glock sync yext && make
	cd $CONGO && git co master && git pull && glock sync congo && glock sync yext && make
	cd $ALPHA && git co master && git pull && make
) &

cd ~/repo/generator-ysp && git co master && git pull && yarn install && yarn link &

cd ~/repo/pages-builder && git pull &

cd ~/repo/pages-tools && git pull &

brew upgrade &

(
	npm i -g npm 
	npm i -g bower
) &

pip install --upgrade pip --user &

cd ~/repo/yext-ce-tools && git pull &

wait