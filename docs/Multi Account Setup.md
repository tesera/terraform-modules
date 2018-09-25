# Master Account Setup

// Testing: will.farrell+master@tetsera.com
## Manual Steps
1. Create Master Account *
1. Must request from support to up the limit for Organizations / Number of Accounts to 6+ from 2
1. Create `terraform` User *
1. Services activation can take up to 24h.
1. `terraform apply` `./master/state`
1. `terraform apply` `./master/account`
1. Delete `terraform` User from account
1. Verify email on master account
1. Setup Sub Accounts *
1. Setup Login Account *

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

### Create `terraform` User
1. Go to IAM.
1. Press `Add User`.
1. Enter `User name` as `terraform`, check `Programmatic access` and press `Next: Permissions`.
1. Press `Attach existing policies directly`, check `AdministratorAccess` and press `Next Review`.
1. Press `Create user`.
1. Copy `Access key ID` and `Secret access key` to `~/.aws/credentials` into `[tmp]`.


### Setup Sub Accounts
1. Set Sub Account Root Password (See [Accessing and Administering the Member Accounts in Your Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html#orgs_manage_accounts_access-as-root))
1. Add `terraform` user w/ admin policy and access keys
1. `terraform apply` `./environments/state`
1. `tfe apply` `./environments/account`
1. Delete `terraform` User from account
1. Repeat for each environments, operations, adn forensics accounts

### Setup Login Account
// User logs in and setts up MFA and generated access keys
1. TODO

## TODO
- how do users log in with/up pass
- how do users assume roles in console
- how do users assume roles in cli
- how to run tf with assumed role
- what is tfe - management of it
