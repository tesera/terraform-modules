
## Potential Issues
If an organization is already created you'll have to import the state
```bash
terraform import module.organization.aws_organizations_organization.account o-****/*****
```

If an account already exists
```bash
terraform import module.organization.aws_organizations_account.environment[0] 111111111111
```
## Tree
```
master
|- ou-environments
|  |- production
|  |- staging
|  |- testing
|  |- development
```


## Inputs

- **type:** Type of account. Must be **master**. [Default: master]
- **account_email:** Email associated with the root sub-accounts
- **sub_accounts:** list of accounts. [Default: [production,staging,testing,development]]

## Sources
- https://www.datadoghq.com/blog/engineering/secure-aws-account-iam-setup/
- https://ashwini.tech/2018/terraform-aws-iam-user/

## TODO
- [ ] Group and policy for terraform users (non-admins)
