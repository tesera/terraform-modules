#!/usr/bin/env bash

# Fail as soon as first command fails
set -e

# Script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Add cleanup function and run it on exit.
function finish {
    if [[ -f "$password_file" ]]; then
        rm "$password_file"
    fi

    if [[ -f "$message_file" ]]; then
        rm "$message_file"
    fi
}
trap finish EXIT

ALIAS="$1"          # AWS Alias name
ADMIN_EMAIL="$2"    # Admin Email addess
USER_EMAIL="$3"     # User Email address
USERNAME="$4"       # Username
ENC_PASSWORD="$5"   # PGP encrypted password

# Uncomment following if using keybase
# PASSWORD=$(base64 --decode | keybase pgp decrypt)

# Create a temporary file to store the encrypted binary data.
password_file=$(mktemp "password.${USERNAME}.gpg")

# Decode the Base64 password and store it in password file.
echo "$ENC_PASSWORD" | base64 --decode > "$password_file"

# Decrypt the password from file. Notice the -q flag.
PASSWORD=$(gpg -q --decrypt "$password_file")

# Remove the password file. No longer needed.
rm "$password_file"

# Create a temporary file to store the HTML email body.
message_file=$(mktemp "message.${USERNAME}.html")

# Replace username and passwords with correct values.
cat "$DIR/send-email.html.tpl" > ${message_file}
sed -i '' -e "s/__USERNAME__/${USERNAME}/g" ${message_file}
sed -i '' -e "s/__PASSWORD__/${PASSWORD}/g" ${message_file}
sed -i '' -e "s/__ALIAS__/${ALIAS}/g" ${message_file}

# Send the email
#aws ses send-email --region us-east-1 \
#    --from "${ADMIN_EMAIL}" \
#    --to "${USER_EMAIL}" \
#    --subject "[IMPORTANT] ${ALIAS} AWS Account Details" \
#    --html "file://${message_file}"

rm "${message_file}"

# OSX Only
cat "$DIR/send-email.txt.tpl" > ${message_file}
sed -i '' -e "s/__USERNAME__/${USERNAME}/g" ${message_file}
sed -i '' -e "s/__PASSWORD__/${PASSWORD}/g" ${message_file}
sed -i '' -e "s/__ALIAS__/${ALIAS}/g" ${message_file}

cat "${message_file}" | mail -s "[IMPORTANT] ${ALIAS} AWS Account Details" ${USER_EMAIL}
