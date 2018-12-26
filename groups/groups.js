
let sub_accounts = process.argv[2].split(',')
let roles = process.argv[3].split(',')

let count = 0
const json = {}
for (let a = sub_accounts.length; a--;) {
  for (let r = roles.length; r--;) {
    const group = `${sub_accounts[a]}-${roles[r]}`
    json[count] = group
    count += 1
  }
}

console.log(JSON.stringify(json))
