$folders = @(
  "37", "6", "A_Knight", "Aleph", "Alexios", "AliEn_T", "An-an_Lee", "Anjo_Nala", "APPLe", "Argus",
  "Avgust", "Baby_Blue", "Balloon_Party", "Barbara", "Barcarola", "Beryl", "Bkornblume", "Blonney", "Brimley", "Brume",
  "Buddy_Fairchild", "Centurion", "Charlie", "Charon", "Cheng_Heguang", "Click", "Coppélia", "Cornerstone", "Corvus", "Cristallo",
  "Darley_Clatter", "Desert_Flannel", "Diggers", "Dikke", "Door", "Druvis_III", "Eagle", "Enigma", "Erick", "Eternity",
  "Everecho", "Ezio_Auditore", "Ezra", "Fatutu", "Flutterpage", "Getian", "Hissabeth", "Horropedia", "Igor", "Isabella",
  "Isolde", "J", "Jessica", "Jiu_Niangzi", "John_Titor", "Kaalaa_Baunaa", "Kakania", "Kanjira", "Kassandra", "Leilani",
  "Liang_Yue", "Lilya", "Loggerhead", "Lopera", "Lorelei", "Lorentz_Butterfly", "Lucy", "Marcus", "Marsha", "Matilda",
  "Melania", "Mercuria", "Mesmer_Jr", "Moldir", "Mondlicht", "Ms._NewBabel", "Ms._Stranger", "Name_Day", "Nautika", "Necrologist",
  "Nick_Bottom", "Noire", "NORA", "Oliver_Fog", "ONiON", "Paper_Heron", "Pavia", "Pickles", "Pioneer", "Ramona",
  "Recoleta", "Reed", "Regulus", "Rhiannon", "Rubuska", "Satsuki", "Semmelweis", "Sentinel", "Shamane", "Silverwing_Eagle",
  "Sonetto", "Sotheby", "Spathodea", "Sputnik", "Sweetheart", "Tennant", "The_Fool", "The_Twins", "Tooth_Fairy", "TTT",
  "Tuesday", "Twins_Sleep", "Ulrich", "Ulu", "vila", "Voyager", "White_Rum", "Willow", "Windsong", "X",
  "Yenisei", "Зима"
)

$rarities = @("4", "5", "6")
$afflatuses = @("Beast", "Plant", "Star", "Mineral", "Intellect", "Spirit")
$roles = @("DPS", "Support", "Tank", "Healer")
$videoFilesByFolder = @{}

function Get-SkillVideoPath($folder, $category, $skillNumber) {
  if (-not $videoFilesByFolder.ContainsKey($folder)) {
    $characterFolder = Join-Path $PSScriptRoot $folder
    if (Test-Path $characterFolder) {
      $videoFilesByFolder[$folder] = @(Get-ChildItem -Path $characterFolder -File -Filter '*_Skill*_Animation.mp4')
    } else {
      $videoFilesByFolder[$folder] = @()
    }
  }

  $files = $videoFilesByFolder[$folder]
  if ($category -eq "origin") {
    $video = $files | Where-Object {
      $_.Name -match "_Skill${skillNumber}_Animation\.mp4$" -and
      $_.Name -notmatch "_Garment\d+_"
    } | Select-Object -First 1
  } else {
    $garmentNumbers = @($files | ForEach-Object {
      $match = [regex]::Match($_.Name, '_Garment(\d+)_')
      if ($match.Success) { [int]$match.Groups[1].Value }
    } | Sort-Object -Unique)
    $garmentIndex = if ($category -eq "character") { 0 } else { 1 }
    if ($garmentNumbers.Count -le $garmentIndex) {
      return ""
    }

    $garmentNumber = $garmentNumbers[$garmentIndex]
    $video = $files | Where-Object {
      $_.Name -match "_Garment${garmentNumber}_Skill${skillNumber}_Animation\.mp4$"
    } | Select-Object -First 1
  }

  if ($video) {
    return "$folder/$($video.Name)"
  }
  return ""
}

$chars = @()
$id = 1

foreach ($folder in $folders) {
  $folderPath = Join-Path $PSScriptRoot $folder
  if (Test-Path $folderPath) {
    $files = Get-ChildItem -Path $folderPath -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg)$' }
    if ($files) {
      $iconFile = $files |
        Where-Object { $_.Name -match '^icon.*\.(png|jpg|jpeg)$' } |
        Sort-Object Name |
        Select-Object -First 1
      $artFile = $files |
        Where-Object { $_.Name -match 'garment1' -and $_.Name -match 'live2d' } |
        Sort-Object Name |
        Select-Object -First 1
      if (-not $artFile) {
        $artFile = $files |
          Where-Object { $_.Name -match 'garment1' } |
          Sort-Object Name |
          Select-Object -First 1
      }
      if (-not $artFile) {
        $artFile = $files |
          Where-Object { $_.Name -match 'live2d' } |
          Sort-Object Name |
          Select-Object -First 1
      }
      if (-not $artFile) {
        $artFile = $files | Sort-Object Name | Select-Object -First 1
      }

      $artPath = "$folder/" + $artFile.Name
      $iconPath = if ($iconFile) { "$folder/" + $iconFile.Name } else { $artPath }

      $displayName = $folder -replace '_', ' '
      $rarity = $rarities[($id + 1) % $rarities.Length]
      $afflatus = $afflatuses[$id % $afflatuses.Length]
      $role = $roles[$id % $roles.Length]
      
      $element = switch ($afflatus) {
        "Beast" { "Beast (Wild)" }
        "Plant" { "Plant (Nature)" }
        "Star" { "Star (Cosmic)" }
        "Mineral" { "Mineral (Crystal)" }
        "Intellect" { "Intellect (Mind)" }
        "Spirit" { "Spirit (Soul)" }
        default { "Plant (Nature)" }
      }

      $badgeIcon = "asset/${afflatus}_Icon.png"
      
      $chars += [PSCustomObject]@{
        Id = $id
        Folder = $folder
        DisplayName = $displayName
        ArtPath = $artPath
        IconPath = $iconPath
        Rarity = $rarity
        Afflatus = $afflatus
        Element = $element
        Role = $role
        BadgeIcon = $badgeIcon
        Hp = 1000 + ($id * 23) % 900
        Atk = 200 + ($id * 13) % 400
        Def = 100 + ($id * 7) % 200
        Crit = 10 + ($id * 3) % 30
        Energy = 100
      }
      $id++
    }
  }
}

Write-Host "Found $($chars.Count) characters with images"
Write-Host ""

# Generate script.js file
$jsContent = @"
/* =========================================================
   CHARACTER / SKIN DATA
   ========================================================= */

const originData = {
"@

foreach ($c in $chars) {
  $jsContent += @"
  $($c.Id): {
    name: "$($c.DisplayName)",
    badges: [{ icon: "$($c.BadgeIcon)", text: "$($c.Role)" }],
    quote: "$($c.DisplayName) ready for battle.",
    image: "$($c.ArtPath)",
    tabimage: "$($c.IconPath)"
  },
"@
}

$jsContent += @"
};

const characterData = {
"@

foreach ($c in $chars) {
  $jsContent += @"
  $($c.Id): {
    name: "$($c.DisplayName)",
    badges: [{ icon: "$($c.BadgeIcon)", text: "$($c.Role)" }],
    quote: "$($c.DisplayName) character skin quote.",
    image: "$($c.ArtPath)",
    tabimage: "$($c.IconPath)"
  },
"@
}

$jsContent += @"
};

const weaponData = {
"@

foreach ($c in $chars) {
  $jsContent += @"
  $($c.Id): {
    name: "$($c.DisplayName)",
    badges: [{ icon: "$($c.BadgeIcon)", text: "$($c.Role)" }],
    quote: "$($c.DisplayName) psychube ready.",
    image: "$($c.ArtPath)",
    tabimage: "$($c.IconPath)"
  },
"@
}

$jsContent += @"
};

const characterStats = {
"@

foreach ($c in $chars) {
  $jsContent += @"
  $($c.Id): { hp: $($c.Hp), atk: $($c.Atk), def: $($c.Def), crit: $($c.Crit), energy: $($c.Energy) },
"@
}

$jsContent += @"
};

const characterRoles = {
"@

foreach ($c in $chars) {
  $jsContent += @"
  $($c.Id): "$($c.Role)",
"@
}

$jsContent += @"
};

const characterElement = {
"@

foreach ($c in $chars) {
  $jsContent += @"
  $($c.Id): "$($c.Element)",
"@
}

$jsContent += @"
};

const weaponNames = {
"@

foreach ($c in $chars) {
  $jsContent += @"
  $($c.Id): "Staff of $($c.DisplayName)",
"@
}

$jsContent += @"
};

const skillData = {
"@

foreach ($c in $chars) {
  $originUltimate = Get-SkillVideoPath $c.Folder "origin" 3
  $originSkill2 = Get-SkillVideoPath $c.Folder "origin" 2
  $originSkill1 = Get-SkillVideoPath $c.Folder "origin" 1
  $characterUltimate = Get-SkillVideoPath $c.Folder "character" 3
  $characterSkill2 = Get-SkillVideoPath $c.Folder "character" 2
  $characterSkill1 = Get-SkillVideoPath $c.Folder "character" 1
  $weaponUltimate = Get-SkillVideoPath $c.Folder "weapon" 3
  $weaponSkill2 = Get-SkillVideoPath $c.Folder "weapon" 2
  $weaponSkill1 = Get-SkillVideoPath $c.Folder "weapon" 1
  $jsContent += @"
  $($c.Id): {
    origin: {
      ultimate: { title: "Ultimate: $($c.DisplayName)", desc: "Unleashes ultimate power.", video: "$originUltimate" },
      "skill-2": { title: "Skill 2: $($c.DisplayName)", desc: "Second skill ability.", video: "$originSkill2" },
      "skill-1": { title: "Skill 1: $($c.DisplayName)", desc: "First skill ability.", video: "$originSkill1" }
    },
    character: {
      ultimate: { title: "Ultimate: $($c.DisplayName)", desc: "Unleashes ultimate power.", video: "$characterUltimate" },
      "skill-2": { title: "Skill 2: $($c.DisplayName)", desc: "Second skill ability.", video: "$characterSkill2" },
      "skill-1": { title: "Skill 1: $($c.DisplayName)", desc: "First skill ability.", video: "$characterSkill1" }
    },
    weapon: {
      ultimate: { title: "Ultimate: $($c.DisplayName)", desc: "Unleashes ultimate power.", video: "$weaponUltimate" },
      "skill-2": { title: "Skill 2: $($c.DisplayName)", desc: "Second skill ability.", video: "$weaponSkill2" },
      "skill-1": { title: "Skill 1: $($c.DisplayName)", desc: "First skill ability.", video: "$weaponSkill1" }
    }
  },
"@
}

$jsContent += @"
};
"@

$jsContent | Out-File (Join-Path $PSScriptRoot "script.js") -Encoding utf8

Write-Host "Generated script.js successfully"

# Read current Index.html
$indexPath = Join-Path $PSScriptRoot "Index.html"
$indexContent = Get-Content $indexPath -Raw

# Generate avatars HTML
$avatarsHtml = ""
foreach ($c in $chars) {
  $avatarsHtml += @"
              <div class="avatar-item" data-id="$($c.Id)">
                <img class="avatar" src="$($c.IconPath)" alt="$($c.DisplayName)">
                <div class="content"><h1>$($c.DisplayName)</h1></div>
              </div>
"@
}

# Replace only the contents of the carousel, preserving its wrapper and controls.
$avatarOpen = '<div class="hero-avatars">'
$nextButton = '<button class="carousel-nav next"'
$avatarOpenIndex = $indexContent.IndexOf($avatarOpen)
$nextButtonIndex = $indexContent.IndexOf($nextButton, $avatarOpenIndex)
if ($avatarOpenIndex -lt 0 -or $nextButtonIndex -lt 0) {
  throw "Could not find the avatar carousel in Index.html"
}
$avatarContentStart = $avatarOpenIndex + $avatarOpen.Length
$avatarCloseIndex = $indexContent.LastIndexOf('</div>', $nextButtonIndex)
if ($avatarCloseIndex -lt $avatarContentStart) {
  throw "Could not find the closing avatar carousel element in Index.html"
}
$newIndexContent = $indexContent.Substring(0, $avatarContentStart) +
  "`r`n$avatarsHtml            " +
  $indexContent.Substring($avatarCloseIndex)

if ($newIndexContent -notmatch '<script src="app\.js"></script>') {
  $newIndexContent = $newIndexContent.Replace(
    '<script src="script.js"></script>',
    "<script src=`"script.js`"></script>`r`n  <script src=`"app.js`"></script>"
  )
}

$newIndexContent | Out-File $indexPath -Encoding utf8

Write-Host "Generated Index.html successfully with $($chars.Count) characters"
