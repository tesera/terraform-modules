
let count = process.argv[2]
const max = process.argv[3]
count = Math.min(Math.max(count, 1), max)

const zones="abcdefghijklmnopqrstuvwxyz"
const json = {}
while (count--) {
  json[count]=zones.substr(count,1)
}

console.log(JSON.stringify(json))
