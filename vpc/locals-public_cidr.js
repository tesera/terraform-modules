
let cidr = process.argv[2].replace('.0.0/16','')
let count = process.argv[3]
const max = process.argv[4]
count = Math.min(Math.max(count, 1), max)

const json = {}
while (count--) {
  json[count]=`${cidr}.${count}.0/24`
}

console.log(JSON.stringify(json))
