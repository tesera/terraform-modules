# IAM User Details
Your IAM account for AWS access has been created. Following are the
account details. The included password is temporary and you will need
to change the password on your first login. You should try signing into
AWS console and change the password immediately and add a MFA
device to your account.

Login URL: https://__ALIAS__.signin.aws.amazon.com/console

AccountID: __ALIAS__
Username: __USERNAME__
Password: __PASSWORD__

## Multi-Factor Authentication (MFA)
1. Go to https://console.aws.amazon.com/iam/home?region=us-east-1#/users/__USERNAME__?section=security_credentials
2. Press `Manage` under `Assigned MFA device`.
3. Choose `Virtual device` and press `Continue`.
4. Scan QRCode into MFA device, enter two MFA codes and press `Assign MFA`.
5. Press `Close`.

## Switch Roles
If you have access to deployed environments, see shared documentation.

Thanks,
The Wizard of Oz
