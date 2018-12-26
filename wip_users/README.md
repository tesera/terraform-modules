
## Limitations
- User can be part of a max 10 groups

## Requirements
- Email only works on MacOS
- PGP Key [GPG Suite]()

### Make GPG Key

```bash
gpg --gen-key
...
gpg --list-keys
# pub   rsa4096/0x0000000000000000 20XX-02-29 [SC] [expires: 20xx-02-29]
gpg --export 0x0000000000000000 | base64 > terraform.pub
```

## Inputs
- **users:** map of users with groups
- **account_alias:** set login alias
- **account_email:** email address to send welcome email from
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
