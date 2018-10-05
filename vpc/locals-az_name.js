
let count = process.argv[2]
const max = process.argv[3]
count = Math.min(Math.max(count, 1), Math.min(max,15))

const zones="abcdefghijklmnopqrstuvwxyz"
const json = {}
while (count--) {
  json[count]=zones.substr(count,1)
}

console.log(JSON.stringify(json))
