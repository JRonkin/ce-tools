#!/usr/bin/env bash
# Backup alpha
cd ~
mv alpha alpha.bak


#################### From machine-setup-mac.sh ####################


# Clone alpha (REQUIRES SSH KEYS GENERATED AND DISTRIBUTED)
git clone ssh://git@stash.office.yext.com:1234/y/alpha.git ~/alpha
git checkout master

# Set up commit-msg hook and use proper remote
cd ~/alpha
[ -d devops/git/hooks ] && for f in devops/git/hooks/*; do ln -sf ../../$f .git/hooks; done
git remote set-url origin ssh://$USER@gerrit.yext.com:29418/alpha
git config --local --add include.path ../devops/git/config/aliases.inc
git config --local --add include.path ../devops/git/config/commit.inc

# Install standardized version of bazel
PLEASE_INSTALL_BAZEL=1 ~/alpha/tools/bazel

# Install Sequel Pro favorites
yes | ~/alpha/tools/sequelpro/install.py

# Set up alpha stuff: build.properties, keyfile.txt
cd ~/alpha
python scripts/python/crypto.py > keyfile.txt
cat > build.properties <<EOF
authentication.login_certificate_file=$HOME/alpha/keyfile.txt
developer.machine=true
EOF

bash alpha/tools/git_hooks/git_hooks_setup.sh

# NOTE: Some cmds require generated proto files, so do that prior to the glock sync
go get github.com/gogo/protobuf/protoc-gen-gogo
go get github.com/golang/protobuf/protoc-gen-go
make -C $HOME/alpha/gocode/src/yext protos

go get github.com/b1lly/gob/gob
go get github.com/robfig/glock
go get github.com/yext/edward
glock install yext
glock sync yext


#################### From consulting-setup-mac.sh ####################


# Convert ALPHA to Gerrit
cd $ALPHA
git remote set-url origin ssh://$(whoami)@gerrit.yext.com:29418/alpha
git fetch origin
ln -sf ../../devops/git/hooks/commit-msg .git/hooks
git config --local --add include.path ../devops/git/config/aliases.inc
git config --local gerrit.ccEmail consulting-dev@yext.com 

# Ensure ~/.profile exists
touch ~/.profile

# install git-up
git config --global alias.up 'pull --rebase --autostash'
git config --global pull.rebase true
git config --global rebase.autoStash true

# clone congo
cd $GOSRC
echo "moved to $(pwd)"
git clone ssh://$(whoami)@gerrit.yext.com:29418/congo
cd $CONGO
./install-git-hooks.sh
make symlink
make setup
glock sync congo
glock sync yext
cd $YEXT
echo "moved to $(pwd)"
make yamls protos easyjson binaries
cd $CONGO
echo "moved to $(pwd)"
make
cd ~
echo "moved to $(pwd)"
