# Master Account Setup

// Testing: will.farrell+master@tetsera.com
## Manual Steps
- [ ] Create Master Account
- [ ] Must request from support to up the limit for Organizations / Number of Accounts to 6+ from 2
- [ ] Create `terraform` User
- [ ] Services activation can take up to 24h.
- [ ] `terraform apply` `./master/state`
- [ ] `terraform apply` `./master/accounts`
- [ ] Verify email on master account
- [ ] Set Sub Account Root Password
- [ ] add `terraform` user w/ admin policy and access keys
- [ ] 

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


### Set Sub Account Root Password
See [Accessing and Administering the Member Accounts in Your Organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_access.html#orgs_manage_accounts_access-as-root).
