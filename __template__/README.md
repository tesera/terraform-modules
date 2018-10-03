# Infrastructure

## Getting Started

### Installing Terraform
```bash
$ brew install terraform
```

### Installing Terraform-Prime
```bash
$ wget **TODO willfarrell/terraform-prime** > /usr/local/bin
```

### Install node dependencies
```bash
$ npm run install:npm
```

## Project Structure

```bash
${project}-infrastructure
|-- package.json	# Script shortcuts (lint, install, deploy, test) & versioning?
|-- master			# Setup for root level account
|   |-- state		# Sets up state management for terraform
|   |-- account     # Account setup (Groups, Monitoring)
|   |-- users		# IAM Users
|-- operations		# Setup for operation pieces
|   |-- account     # Account setup (Roles, Monitoring)
|   |-- cicd		# Jenkins
|   |-- dns			# Route53
|   |-- logging		# ELK & CloudWatch
|   |-- secrets		# HashiCorp Vault
|-- environments
|   |-- account     # Account setup (Roles, Monitoring)
|   |-- app			# Public static assets
|   |-- api			# Public/Private API endpoints and support infrastructure
|   |-- dashboard	# Ops dashboards
|   |-- db			# Databases
|   |-- vpc			# VPC & Networking
|-- modules			# Collection of project specific modules
```

## Accounts

Name        | ID           | Root Email         |
------------|--------------|--------------------|
master      |              |                    |
operations  |              |                    |
production  |              |                    |
staging     |              |                    |
testing     |              |                    |
development |              |                    |
forensics   |              |                    |

TODO add in suggested colours

## Switch Roles
- `admin`
- `developer`

TODO complete policy for developer
TODO add in `audit` role?

## Built With
- [Terraform](https://www.terraform.io/)
- [NodeJS](https://nodejs.org/en/)

## Contributing
See Developer Guide (TODO add link)

## Versioning
We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/tesera/terraform-modules/tags).

## Authors
- [will Farrell](https://github.com/willfarrell)

See also the list of [contributors](https://github.com/tesera/terraform-modules/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments


## TODO / Roadmap
- [ ] on commit lint `terraform fmt`
- [ ] Setup Vault - http://www.singulariti.co/2018/03/30/tech-blog-hashicorp-stack-for-secrets-management/




