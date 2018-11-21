cd $ALPHA/gocode/src/yext && git pull && glock save yext && glock sync yext && make protos && make binaries &

cd $CONGO && git pull && glock save yext && glock sync yext && make protos && make binaries &

cd ~/repo/generator-ysp && git pull &

cd ~/repo/pages-builder && git pull &

cd ~/repo/pages-tools && git pull &

cd ~/repo/yext-ce-tools && git pull &

brew upgrade &

npm i -g npm &

pip install --upgrade pip --user &

wait