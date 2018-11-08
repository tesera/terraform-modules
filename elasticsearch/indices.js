const elasticsearch = require('elasticsearch');
const fs = require('fs');

const mappings = JSON.parse(fs.readFileSync(process.argv[2]));
const params = {
  host: { "protocol": "https", "host": process.argv[3], "port": process.argv[4] },
  requestTimeout: 10 * 60 * 1000
};

const client = elasticsearch.Client(params);

mappings.forEach(mapping => {
  const alias = mapping.index;
  mapping.index = mapping.index.toLowerCase() + '-' + (new Date()).getTime();
  client.indices.create(mapping)
    .then((data) => {
      console.log(data);
      client.indices.putAlias({ index: mapping.index, name: alias })
        .then((data) => {
          console.log(`created alias ${alias} => ${mapping.index}`);
          console.log(data);
        })
        .catch((err) => {
          console.error(err);
          process.exit(1);
        });
    })
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
});
