const fs = require("fs");
const path = require("path");
const vm = require("vm");

const context = {};
vm.createContext(context);
vm.runInContext(
  `${fs.readFileSync("script.js", "utf8")}; globalThis.data = { originData, characterData, weaponData, characterStats, characterRoles, characterElement, weaponNames, skillData };`,
  context
);

const datasets = context.data;
const ids = Object.keys(datasets.originData);
const missing = [];
for (const [name, data] of Object.entries(datasets)) {
  for (const id of ids) {
    if (!data[id]) missing.push(`${name}: missing ID ${id}`);
  }
}

const assets = [];
for (const [category, data] of Object.entries(datasets)) {
  for (const [id, entry] of Object.entries(data)) {
    for (const field of ["image", "tabimage"]) {
      if (entry[field] && !fs.existsSync(path.resolve(entry[field]))) {
        assets.push(`${category} ID ${id} ${field}: ${entry[field]}`);
      }
    }
  }
}

console.log("Missing IDs:");
console.log(missing.join("\n") || "none");
console.log("\nMissing assets:");
console.log(assets.join("\n") || "none");
