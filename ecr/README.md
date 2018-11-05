# GitHub to ECR



## Features
- [ ] github webhooks
- [ ] gitflow built in
- [ ] ability to retrigger a build for a commit

### Tags
- development: last commit to the `develop` branch
- testing: last commit to a `release/*` branch
- staging: last commit to a `release/*` branch w/ a `tag`
- production: last commit to the `master` branch w/ a `tag`
- latest: last commit to the `master` branch
- `tag`: commit with a `tag`


## Deployment
### Setup OAuth Token
TODO: add image
1. Go to `https://github.com/settings/tokens`, press `Generate new token`, select `scopes:repo`, press `Generate token`.
1. Run:
```bash
SECRET=$(ruby -rsecurerandom -e 'puts SecureRandom.hex(20)')
aws ssm put-parameter --overwrite --name '/github/ci-otp' --value "$GITHUB_OAUTH_TOKEN" --type SecureString --region us-east-1 --profile default
aws ssm put-parameter --overwrite --name '/github/ci-pr-webhook-secret' --value "$SECRET" --type SecureString --region us-east-1 --profile default
```

### Terraform
```hcl-terraform
module "docker" {
  #source              = "git@github.com:tesera/terraform-modules//public-api-gateway?ref=feature/apig2"
  source = "../../ecr"

  ecr = [
    "nginx",
    "node",
    "faas"
  ]
}

output "url" {
  value = "${module.docker.url}"
}

```

### Setup Webhook
TODO: add image

#### Params
Additional params for the webhook. Defaults assume 1:1 for repo:image, can easily do 1:n.
- **name:** name of the ECR. [Default: `${repo_owner}-${repo_name}`]
- **dockerfile:** path to the dockerfile. [Default: `/`]



## Refs
- https://developer.github.com/webhooks/securing/
- https://developer.github.com/v3/activity/events/types
- https://github.com/nicolai86/awesome-codepipeline-ci
- https://github.com/serverless/examples/blob/master/aws-node-github-webhook-listener/handler.js
