
let cidr = process.argv[2].replace('.0.0/16','')
let count = process.argv[3]
count = Math.min(Math.max(count, 1), 15)

const json = {}
while (count--) {
  json[count]=`${cidr}.${(count+1)*16}.0/20`
}

console.log(JSON.stringify(json))
