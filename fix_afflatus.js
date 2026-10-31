const fs = require('fs');

// Corrections map: ID -> correct Afflatus
const corrections = {
  12: 'Star',
  14: 'Spirit',
  15: 'Star',
  17: 'Plant',
  19: 'Mineral',
  20: 'Beast',
  21: 'Plant',
  22: 'Beast',
  23: 'Star',
  24: 'Spirit',
  25: 'Star',
  26: 'Spirit',
  29: 'Mineral',
  31: 'Beast',
  32: 'Plant',
  35: 'Plant',
  36: 'Plant',
  37: 'Intellect',
  40: 'Mineral',
  41: 'Star',
  42: 'Star',
  43: 'Mineral',
  45: 'Beast',
  46: 'Plant',
  47: 'Mineral',
  50: 'Spirit',
  51: 'Beast',
  52: 'Plant',
  53: 'Mineral',
  54: 'Intellect',
  55: 'Mineral',
  56: 'Plant',
  57: 'Plant',
  59: 'Beast',
  60: 'Star',
  61: 'Star',
  62: 'Plant',
  63: 'Beast',
  64: 'Star',
  65: 'Intellect',
  66: 'Intellect',
  69: 'Star',
  70: 'Beast',
  72: 'Intellect',
  73: 'Beast',
  74: 'Mineral',
  76: 'Mineral',
  77: 'Mineral',
  78: 'Spirit',
  79: 'Mineral',
  80: 'Beast',
  81: 'Plant',
  83: 'Star',
  84: 'Mineral',
  86: 'Beast',
  88: 'Spirit',
  89: 'Plant',
  90: 'Plant',
  93: 'Beast',
  94: 'Mineral',
  95: 'Plant',
  96: 'Mineral',
  97: 'Mineral',
  98: 'Beast',
  99: 'Plant',
  100: 'Mineral'
};

// Read file
let content = fs.readFileSync('D:\\WEB\\APK\\script.js', 'utf8');

// Process each correction
for (const [id, afflatus] of Object.entries(corrections)) {
  const idNum = parseInt(id);
  
  // Pattern to match both characterSkinData and characterData
  const pattern = new RegExp(
    `(\\s+${idNum}:\\s*{\\s*name:\\s*"[^"]+",\\s*badges:\\s*\\[\\{\\s*icon:\\s*"asset/)([^_]+)(_Icon\\.png"[^}]+}\\])`,
    'g'
  );
  
  content = content.replace(pattern, `$1${afflatus}$3`);
}

// Write back
fs.writeFileSync('D:\\WEB\\APK\\script.js', content, 'utf8');

console.log('✓ Fixed', Object.keys(corrections).length, 'character Afflatus badges');
