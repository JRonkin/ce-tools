cd $ALPHA/gocode/src/yext && git pull && glock sync yext && make protos && make binaries &

brew upgrade &

cd ~/repo/generator-ysp && git pull &

cd ~/repo/pages-builder && git pull &

cd ~/repo/pages-tools && git pull &

cd ~/repo/yext-ce-tools && git pull &

wait