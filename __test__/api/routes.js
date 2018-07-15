const fs = require('fs')

const makeId = (path, method = null) => `${method ? method+'_' : ''}${path.toLowerCase().substr(1).replace('/','_')}`

const resource = (input, name, path_part, parent_id = '${module.api.root_resource_id}') => `
resource "aws_api_gateway_resource" "${name}" {
  rest_api_id = "${input.rest_api_id}"
  parent_id   = "${parent_id}"
  path_part   = "${path_part}"
}
`

const endpoint = (input, name, id, src) => `
module "${name}" {
  source             = "${input.source}"
  name               = "${input.name}"
  security_group_ids = ["${input.security_group_ids}"]
  private_subnet_ids = ["${input.private_subnet_ids}"]
  rest_api_id        = "${input.rest_api_id}"
  resource_id        = "\${aws_api_gateway_resource.${id}.id}"
  http_method        = "GET"
  stage_name         = "${input.stage_name}"
  resource_path      = "\${aws_api_gateway_resource.${id}.path}"
  source_dir         = "\${path.module}/${src}"
}
`

const resources = {}

const buildResources = (input, path) => {
  const parts = path.substr(1).split('/')
  const paths = []
  let last_id = null
  while(parts.length) {
    paths.push(parts.shift())
    const id = makeId(`/${paths.join('/')}`)
    console.log(id, paths[paths.length-1])
    if (resources[id]) {
      last_id = id
      continue;
    }

    if (paths.length === 1) {
      output += resource(input, id, paths[paths.length-1])
    } else {
      output += resource(input, id, paths[paths.length-1], `\${aws_api_gateway_resource.${last_id}.id}`)
    }

    resources[id] = true

    last_id = id
  }

  return last_id
}

// Run
const input = JSON.parse(fs.readFileSync('routes.json'))
input.args = Object.assign({
  "source": "../../public-api-endpoint",
  "name": "${local.name}",
  "security_group_ids": "${module.api.secuity_group_id}",
  "private_subnet_ids": "${data.vpc.private_subnet_ids}",
  "rest_api_id": "${module.api.rest_api_id}",
  "stage_name": "${module.api.stage_name}"
}, input.args)
let output = '# ***** Generated by Makefile *****'

input.routes.forEach((route) => {
  const name = makeId(route.path, route.method)
  const id = buildResources(input.meta, route.path)
  output += endpoint(input.meta, name, id, route.src)
})

console.log( output )

fs.writeFileSync('routes.tf', output, 'utf8')
