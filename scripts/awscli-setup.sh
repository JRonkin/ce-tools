# install AWS-CLI
AWS_ACCOUNT_NUM='940787264688'
AWS_ACCOUNT_ROLE='prod-ReadOnly'
okta_username="$(basename $HOME)"
aws_account="${AWS_ACCOUNT_NUM}/${AWS_ACCOUNT_ROLE}/${okta_username}@yext.com"

mkdir "${HOME}/.okta"

curl -L -o "${HOME}/.okta/oktaawscli.jar" 'https://github.com/oktadeveloper/okta-aws-cli-assume-role/releases/download/v1.0.10/okta-aws-cli-1.0.10.jar'

echo 'cd "${BASH_SOURCE%/*}" || exit
java -classpath .:oktaawscli.jar com.okta.tools.awscli $@' > "${HOME}/.okta/awscli"
chmod +x "${HOME}/.okta/awscli"

echo "OKTA_ORG=yext.okta.com
OKTA_AWS_APP_URL=https://yext.okta.com/home/amazon_aws/0oa1ekflhqejxdJ391d8/272
OKTA_STS_DURATION=43200
OKTA_USERNAME=${okta_username}" > "${HOME}/.okta/config.properties"

mkdir "${HOME}/.aws"
echo "[default]
role_arn = arn:aws:iam::${AWS_ACCOUNT_NUM}:role/${AWS_ACCOUNT_ROLE}
source_profile = ${AWS_ACCOUNT_ROLE}_${AWS_ACCOUNT_NUM}
region = us-east-1

[profile ${aws_account}]
role_arn = arn:aws:iam::${AWS_ACCOUNT_NUM}:role/${AWS_ACCOUNT_ROLE}
source_profile = ${AWS_ACCOUNT_ROLE}_${AWS_ACCOUNT_NUM}
region = us-east-1
" > "${HOME}/.aws/config"

pip install awscli --upgrade --user

echo >> "${HOME}/.bash_profile"
cat "${HOME}/.bash_profile" |
	grep -v '# AWS-CLI' |
	grep -v "export PATH=\$PATH:${HOME}/Library/Python/2.7/bin" |
	grep -v "export PATH=\$PATH:${HOME}/.okta" |
	grep -v 'export AWS_DEFAULT_PROFILE=' |
	uniq > "${HOME}/.bash_profile.tmp" &&
	mv "${HOME}/.bash_profile.tmp" "${HOME}/.bash_profile"

echo "# AWS-CLI
export PATH=\$PATH:${HOME}/Library/Python/2.7/bin
export PATH=\$PATH:${HOME}/.okta
export AWS_DEFAULT_PROFILE=${aws_account}
" >> "${HOME}/.bash_profile"