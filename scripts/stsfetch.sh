#!/bin/bash


# Prompt for MFA token
read -p "Enter MFA token: " TOKEN_CODE

# Run AWS STS command to get session token
SESSION=$(aws sts get-session-token --profile permanent --serial-number arn:aws:iam::ACCOUNTNUMBER:mfa/USERNAME --token-code $TOKEN_CODE 2>&1)

# Check if the aws sts command was successful
if [ $? -ne 0 ]; then
  echo "Error: AWS STS get-session-token command failed."
  echo "$SESSION"
  exit 1
fi

# Debug: Output the session JSON
echo "SESSION JSON: $SESSION"

# Parse the session token JSON response and update ~/.aws/credentials
AWS_ACCESS_KEY_ID=$(echo $SESSION | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $SESSION | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo $SESSION | jq -r '.Credentials.SessionToken')

# Check if parsing was successful
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
  echo "Error: Unable to parse AWS credentials."
  exit 1
fi

# Debug: Output the parsed credentials
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
echo "AWS_SESSION_TOKEN: $AWS_SESSION_TOKEN"

# Backup permanent credentials
PERMANENT_AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile permanent)
PERMANENT_AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile permanent)

# Overwrite ~/.aws/credentials with new credentials
cat > ~/.aws/credentials <<EOL
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
aws_session_token=$AWS_SESSION_TOKEN

[permanent]
aws_access_key_id=$PERMANENT_AWS_ACCESS_KEY_ID
aws_secret_access_key=$PERMANENT_AWS_SECRET_ACCESS_KEY
EOL

echo "AWS credentials updated successfully."