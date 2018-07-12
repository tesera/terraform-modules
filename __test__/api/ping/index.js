const handler = (event, context, callback) => {

  return callback(
    null,
    {
      statusCode: 200,
      body:JSON.stringify({data:{success:true}})
    }
  )
}

module.exports = {handler}
