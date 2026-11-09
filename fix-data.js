const fs = require('fs');
let content = fs.readFileSync('script.js', 'utf8');

// Fix 1: Add ID 121 to characterStats
content = content.replace(
  '120: { hp: 1060, atk: 560, def: 140, crit: 10, energy: 100 },};',
  '120: { hp: 1060, atk: 560, def: 140, crit: 10, energy: 100 },  121: { hp: 1083, atk: 573, def: 147, crit: 13, energy: 100 },};'
);

// Fix 2: Add ID 121 to weaponNames
content = content.replace(
  '120: "Staff of Yenisei",};',
  '120: "Staff of Yenisei",  121: "Staff of Зима",};'
);

// Fix 3: Remove characterData IDs 122-130 - find and remove the section
const cd122start = content.indexOf('\n  },  122: {');
const cd130end = content.indexOf('\n  },};', cd122start);
if (cd122start > 0 && cd130end > cd122start) {
  content = content.substring(0, cd122start) + '\n  },};' + content.substring(cd130end + 7);
}

// Fix 4: Remove weaponData IDs 122-130
const wd122start = content.indexOf('\n  },  122: {', content.indexOf('const weaponData'));
const wd130end = content.indexOf('\n  },};', wd122start);
if (wd122start > 0 && wd130end > wd122start) {
  content = content.substring(0, wd122start) + '\n  },};' + content.substring(wd130end + 7);
}

// Fix 5: Fix characterElement ID 121 typo and remove 122-130
content = content.replace(
  '121: "Plant4 (Nature)",',
  '121: "Plant (Nature)",'
);

// Find and remove element IDs 122-130
const ce122start = content.indexOf('122: "Star (Cosmic)",', content.indexOf('const characterElement'));
const ce130end = content.indexOf('};', ce122start);
if (ce122start > 0) {
  content = content.substring(0, ce122start - 2) + '};' + content.substring(ce130end + 2);
}

fs.writeFileSync('script.js', content, 'utf8');
console.log('✓ Fixed data consistency');
