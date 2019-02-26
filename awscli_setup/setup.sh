AWS_ACCOUNT_NUM='940787264688'
AWS_ACCOUNT_ROLE='prod-ReadOnly'


cd "$(dirname "${BASH_SOURCE[0]}")"

read -p 'Okta username (without "@yext.com"): ' username
aws_account="${AWS_ACCOUNT_NUM}/${AWS_ACCOUNT_ROLE}/${username}@yext.com"

cp -Rf files/okta-aws-cli/ "$HOME/.okta-aws-cli"
echo "OKTA_USERNAME=${username}" >> "${HOME}/.okta-aws-cli/config.properties"

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
	grep -v "export PATH=\$PATH:${HOME}/.okta-aws-cli" | 
	grep -v 'export AWS_DEFAULT_PROFILE=' |
	uniq > "${HOME}/.bash_profile.tmp" &&
	mv "${HOME}/.bash_profile.tmp" "${HOME}/.bash_profile"

echo "# AWS-CLI
export PATH=\$PATH:${HOME}/Library/Python/2.7/bin
export PATH=\$PATH:${HOME}/.okta-aws-cli
export AWS_DEFAULT_PROFILE=${aws_account}
" >> "${HOME}/.bash_profile"

export PATH=$PATH:${HOME}/Library/Python/2.7/bin
export PATH=$PATH:${HOME}/.okta-aws-cli
export AWS_DEFAULT_PROFILE=${aws_account}

awscli logout
awscli sts get-caller-identity
