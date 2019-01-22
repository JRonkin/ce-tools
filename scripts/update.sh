cd $YEXT && git pull && glock sync yext && make &

cd $CONGO && git pull && glock sync congo && glock sync yext && make &

cd ~/repo/generator-ysp && git pull &

cd ~/repo/pages-builder && git pull &

cd ~/repo/pages-tools && git pull &

cd ~/repo/yext-ce-tools && git pull &

brew upgrade &

npm i -g npm &

npm i -g bower &

pip install --upgrade pip --user &

wait