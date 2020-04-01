# Groups
Setup groups required for multi-account adn common use cases.

## Requirements
- IDs of sub-accounts

## Inputs
- **type:** Account type. Master / Member. Default: `master`
- **roles:** List of roles that will be in sub accounts.
- **sub_accounts:** Map of sub account names to account IDs.
- **role_mfa:** Enable MFA or not. [Default: "false"]

## Output
- **list:** List of group created


## Master Accout
```hcl-terraform

```

## Sub-Account
See `roles` module.
