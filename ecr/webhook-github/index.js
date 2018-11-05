const AWS = require('aws-sdk')
const crypto = require('crypto')
const octokit = require('@octokit/rest')()
const WebhooksApi = require('@octokit/webhooks')

const codepipeline = new AWS.CodePipeline()

function signRequestBody(key, body) {
  return `sha1=${crypto.createHmac('sha1', key).update(body, 'utf-8').digest('hex')}`;
}

const pipelineName = (params) => {
  let str = `${params.owner}-${params.name}-${params.branch}`
  if (params.pr) str += `-pr-${params.pr}`
  return str
}

const pipelineExists = (name) => {
  return false
  // return codepipeline.getPipeline({name})
}
const clonePipeline = (template, params, commit) => {

}
const destroyPipeline = (name) => {
  return false
  // return codepipeline.deletePipeline({name})
}

const app = async (event, context) => {

  let errMsg; // eslint-disable-line
  const headers = event.headers;

  if (typeof context.GITHUB_WEBHOOK_SECRET !== 'string') {
    errMsg = 'Must provide a \'GITHUB_WEBHOOK_SECRET\' env variable';
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'text/plain' },
      body: errMsg,
    }
  }

  const sig = headers['X-Hub-Signature'];
  if (!sig) {
    errMsg = 'No X-Hub-Signature found on request';
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'text/plain' },
      body: errMsg,
    };
  }

  const githubEvent = headers['X-GitHub-Event'];
  if (!githubEvent) {
    errMsg = 'No X-Github-Event found on request';
    return {
      statusCode: 422,
      headers: { 'Content-Type': 'text/plain' },
      body: errMsg,
    };
  }

  const id = headers['X-GitHub-Delivery'];
  if (!id) {
    errMsg = 'No X-Github-Delivery found on request';
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'text/plain' },
      body: errMsg,
    };
  }

  const calculatedSig = signRequestBody(context.GITHUB_WEBHOOK_SECRET, event.body);
  if (sig !== calculatedSig) {
    errMsg = 'X-Hub-Signature incorrect. Github webhook token doesn\'t match';
    return {
      statusCode: 401,
      headers: { 'Content-Type': 'text/plain' },
      body: errMsg,
    };
  }

  /* eslint-disable */
  console.log('---------------------------------');
  console.log(`Github-Event: "${githubEvent}" with action: "${event.body.action}"`);
  console.log('---------------------------------');
  console.log('Payload', event.body);
  /* eslint-enable */

  // For more on events see https://developer.github.com/v3/activity/events/types/

  if (event.body.action === 'pull_request') {
    // https://developer.github.com/v3/activity/events/types/#pullrequestevent
    const state = event.body.pull_request.state
    const owner = event.body.pull_request.head.repo.owner.login
    const name = event.body.pull_request.head.repo.name
    const branch = event.body.pull_request.base.ref
    const pr = event.body.pull_request.number
    const ref = event.body.pull_request.head.ref

    const pipelineName = pipelineName({owner, name, branch, pr})
    if (state === 'open') {
      if (!pipelineExists(pipelineName)) {
        clonePipeline(process.env.CODEPIPELINE_TEMPLATE, {
          owner, name, branch, pr
        }, ref)
      }
    } else if (state === 'closed') {
      if (pipelineExists(pipelineName)) {
        destroyPipeline(pipelineName)
      }
    }

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'text/plain' ,
        'X-GitHub-Delivery': context.header['X-GitHub-Delivery']
      },
      body: errMsg,
    };

  } else if (event.body.action === 'push') {
    // https://developer.github.com/v3/activity/events/types/#pushevent

  }

  const response = {
    statusCode: 200,
    body: JSON.stringify({
      input: event,
    }),
  };

  return response;
}

const inputSchema = {type: 'object'}
const outputSchema = {type: 'object'}

const handler = require('./middleware')(app, {
  inputSchema,
  outputSchema,
  env: {
    GITHUB_TOKEN: '/githu/ci-otp',
    GITHUB_WEBHOOK_SECRET: '/github/ci-pr-webhook-secret'
  }
})

module.exports = { handler }
