# Terraform
Collection of frequently used modules and how to start a new project.

## Enterprise by Default
- Encryption at Rest (AES256 or KMS)
- Encryption in Transit (TLSv1.2)
- High availability and redundancy (Multi AZ)
- Least permission roles
- Tags: (Name, Terraform, Cost-Center, Environment)

## Getting Started

### Installing Terraform
```bash
$ brew install terraform
```

### Install node dependencies
```bash
TODO - script to find all package.json and install deps
# find . -type f -name "package.json" | grep -v node_modules | npm i
```

## Project Structure

```bash
${project}-infrastructure
|-- package.json	# script shortcuts (lint, install, deploy, test) & versioning?
|-- master			# Setup for root level account
|   |-- users		# IAM roles
|   |-- state		# Sets up state management for terraform
|-- operations		# Setup for operation pieces
|   |-- cicd		# Jenkins
|   |-- dns			# Route53
|   |-- logging		# ELK & CloudWatch
|   |-- monitoring	# CloudTrail
|   |-- secrets		# HashiCorp Vault
|   |-- state		# Sets up state management for terraform
|-- environments
|   |-- app			# Public static assets
|   |-- api			# Public/Private API endpoints and support infrastructure
|   |-- dashboard	# Ops dashboards
|   |-- db			# Databases
|   |-- state		# Sets up state management for terraform
|   |-- users		# Sets up IAM roles for users
|   |-- vpc			# VPC & Networking
|-- modules			# collection of project specific modules
```

Most application will have similar modules, most included in this project. Execution order is important.

1. state
1. users
1. vpc
1. db
1. api
1. app
1. dashboard

Each environment module will follow the following format.
```
${module}
|-- main.tf						# Includes state management & module inclusion
|-- terraform.tfvars			# Includes ENV that apply to all env
|-- env.development.tfvars.enc	# Includes `development` ENV
|-- env.testing.tfvars.enc		# Includes `testing` ENV
|-- env.staging.tfvars.enc		# Includes `staging` ENV
|-- env.production.tfvars.enc	# Includes `production` ENV
```

All `env.*.tfvars` will be encrypted. (TODO add in script to do that with CI/CD)

Project specific modules should follow the following structure:
```bash
modules
|-- waf
|   |-- variables.tf	# inputs
|   |-- locals.tf		# internal variables
|   |-- main.tf			# setup
|   |-- ...				# tf file for each logical part of the module
|   |-- output			# outputs

```

## Deployment
```bash
$ terraform apply -var-file=env.${environment}.${region}.tfvars
# review changes
$ yes
```

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


