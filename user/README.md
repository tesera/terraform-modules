
## Limitations
- User can be part of a max 10 groups

## Requirements
- Email only works on MacOS
- 

## Inputs

- **pgp_key_path:** path to `terraform.pub`. Generate using `gpg --export __YOUR_GPG_KEY_ID__ | base64 > terraform.pub`.


## Sources
- https://www.datadoghq.com/blog/engineering/secure-aws-account-iam-setup/
- https://ashwini.tech/2018/terraform-aws-iam-user/

## TODO
- [ ] Group and policy for terraform users (non-admins)
- [ ] split users into own module
  - [ ] keys(users), sorts first which will cause issues with add/del ** 
  - [ ] auto generate key
  - [ ] gpg save and shared? Commit pub key into repo?
  - [ ] Email user credentials - SES requires email/domain to be verified before sending. (https://github.com/terraform-providers/terraform-provider-aws/issues/469)
  - [ ] Add in ssh key injection from GitHub
