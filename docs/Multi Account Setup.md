# Master Account Setup

## Manual Steps
1. Create Master Account *
1. Must request from support to up the limit for Organizations / Number of Accounts to 6+ from 2
1. Create `terraform` User *
1. Services activation can take up to 24h.
1. `terraform apply` `./master/state`
1. `terraform apply` `./master/account`
1. You should of received an `AWS Organizations email verification request`, Click `Verify your email address` in the email
1. `terraform apply` `./master/users`
1. Setup Login Account *
1. Delete `terraform` User from account
1. Setup Sub Accounts *

\* See collection of steps below.

### Create Master Account
See [How do I create and activate a new Amazon Web Services account?](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
1. Go to [AWS](https://aws.amazon.com/).
1. Click `Create an AWS Account`, orange button in the top right corner.
1. Enter `Email` (aws+master@example.com), `Password`, `Confirm Password`, `AWS account name` (master) and press `Continue`.
1. Enter `Account type` (Professional), remaining fields and press `Create Account and Continue`.
1. Enter payment information and press `Secure Submit`.
1. Enter `Securitty Check` and press `Call me now`.
1. Enter 4-digit code into your phone after picking up and press `Continue`.
1. Press `Free`.
1. Setup MFA *
1. Add 

### Create `terraform` User
1. Go to IAM.
1. Press `Add User`.
1. Enter `User name` as `terraform`, check `Programmatic access` and press `Next: Permissions`.
1. Press `Attach existing policies directly`, check `AdministratorAccess` and press `Next Review`.
1. Press `Create user`.
1. Copy `Access key ID` and `Secret access key` to `~/.aws/credentials` into `[username]`.
1. Press `Close`.


### Setup Sub Accounts
1. Set Sub Account Root Password (See [Accessing and Administering the Member Accounts in Your Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html#orgs_manage_accounts_access-as-root))
1. Add `terraform` user w/ admin policy and access keys
1. `terraform apply` `./environments/state`
1. `terraform apply` `./environments/account`
1. Delete `terraform` User from account
1. Repeat for each environments, operations, adn forensics accounts

### Setup Login Account
1. Go to [AWS Console Login](https://console.aws.amazon.com/iam/home/) (https://${alias}.signin.aws.amazon.com/console)
1. Enter `Account ID or alias`, `IAM user name`, and `Passowrd` and press `Sign In`.
1. Enter `Old Password`, `New password`, `Retype new password` and press `Confirm password change`.
1. Got to [`IAM`](https://console.aws.amazon.com/iam/) if not already there.
1. Setup MFA *
1. Press `Create access key`.
1. Replace `Access key ID` and `Secret access key` in `~/.aws/credentials` for `[username]` to new credentials.

### Create Access Keys
1. Got to [`IAM`](https://console.aws.amazon.com/iam/home/) if not already there.
1. Click `Users` -> `${username}` -> `Security credentials` -> `Create access key` under `Access Keys`.
1. Copy into `~/.aws/credentials`.

```bash
[main]
aws_access_key_id = access_key_id
aws_secret_access_key = secret_access_key
```

### Setup MFA
1. Got to [`IAM`](https://console.aws.amazon.com/iam/home/) if not already there.
1. Click `Users` -> `${username}` -> `Security credentials` -> `Manage` beside `Assigned MFA device:`. 
1. Choose `Virtual device` and press `Continue`.
1. Click `Show QR code` and scan QRCode into MFA device.
1. Enter `MFA code 1`, wait ~30sec, enter `MFA code 2` and press `Assign MFA`.
1. Press `Close`.

### Setup `Switch Role` in Console
1. From account drop down choose `Switch Role`.
1. Press `Switch Role`.
1. Enter `Account` (ID), `Role`, `Display Name` and press `Switch Role`.

### Setup `Assume Role` in CLI
Update `~/.aws/credentials`:
```bash
[main-environment]
source_profile = main
role_arn = arn:aws:iam:${account_id}:role/admin
session_name = main-environment
```

## Enabled Account level services

### Trusted Advisor
1. Go to [Trusted Advisor Dashboard](https://console.aws.amazon.com/trustedadvisor/home)
1. TODO https://aws.amazon.com/premiumsupport/trustedadvisor/

### Macie
1. [Set Up](https://docs.aws.amazon.com/macie/latest/userguide/macie-setting-up.html#macie-setting-up-enable)

