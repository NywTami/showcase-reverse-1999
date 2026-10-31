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

$chars = @()
$id = 1

foreach ($folder in $folders) {
  $folderPath = "D:\WEB\APK\$folder"
  if (Test-Path $folderPath) {
    $files = Get-ChildItem -Path $folderPath -File | Where-Object { $_.Extension -match '\.(png|jpg|jpeg)$' }
    if ($files) { 
      $iconPath = $null
      $iconFile = $files | Where-Object { $_.Name -match 'icon' }
      if ($iconFile) {
        $iconPath = "$folder/" + $iconFile[0].Name
      } else {
        $g1l2d = $files | Where-Object { $_.Name -match 'garment1' -and $_.Name -match 'live2d' }
        if ($g1l2d) {
          $iconPath = "$folder/" + $g1l2d[0].Name
        } else {
          $g1 = $files | Where-Object { $_.Name -match 'garment1' }
          if ($g1) {
            $iconPath = "$folder/" + $g1[0].Name
          } else {
            $iconPath = "$folder/" + $files[0].Name
          }
        }
      }

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

$nl = [Environment]::NewLine

$scriptJs = "/* =========================================================`n   CHARACTER / SKIN DATA`n   ========================================================= */$nl$nl"

$scriptJs += "const originData = {$nl"
foreach ($c in $chars) {
  $scriptJs += "  $($c.Id): {$nl"
  $scriptJs += "    name: `"$($c.DisplayName)`",$nl"
  $scriptJs += "    badges: [{ icon: `"$($c.BadgeIcon)`", text: `"$($c.Role)`" }],$nl"
  $scriptJs += "    quote: `"$($c.DisplayName) ready for battle.`",$nl"
  $scriptJs += "    image: `"$($c.IconPath)`",$nl"
  $scriptJs += "    tabimage: `"$($c.IconPath)`"$nl"
  $scriptJs += "  },$nl"
  }
  $scriptJs += "};$nl$nl"

  $scriptJs += "const characterData = {$nl"
foreach ($c in $chars) {
  $scriptJs += "  $($c.Id): {$nl"
  $scriptJs += "    name: `"$($c.DisplayName)`",$nl"
  $scriptJs += "    badges: [{ icon: `"$($c.BadgeIcon)`", text: `"$($c.Role)`" }],$nl"
  $scriptJs += "    quote: `"$($c.DisplayName) character skin quote.`",$nl"
  $scriptJs += "    image: `"$($c.IconPath)`",$nl"
  $scriptJs += "    tabimage: `"$($c.IconPath)`"$nl"
  $scriptJs += "  },$nl"
}
$scriptJs += "};$nl$nl"

$scriptJs += "const weaponData = {$nl"
foreach ($c in $chars) {
  $scriptJs += "  $($c.Id): {$nl"
  $scriptJs += "    name: `"$($c.DisplayName)`",$nl"
  $scriptJs += "    badges: [{ icon: `"$($c.BadgeIcon)`", text: `"$($c.Role)`" }],$nl"
  $scriptJs += "    quote: `"$($c.DisplayName) psychube ready.`",$nl"
  $scriptJs += "    image: `"$($c.IconPath)`",$nl"
  $scriptJs += "    tabimage: `"$($c.IconPath)`"$nl"
  $scriptJs += "  },$nl"
}
$scriptJs += "};$nl$nl"

$scriptJs += "const characterStats = {$nl"
foreach ($c in $chars) {
  $scriptJs += "  $($c.Id): { hp: $($c.Hp), atk: $($c.Atk), def: $($c.Def), crit: $($c.Crit), energy: $($c.Energy) },$nl"
}
$scriptJs += "};$nl$nl"

$scriptJs += "const characterRoles = {$nl"
foreach ($c in $chars) {
  $scriptJs += "  $($c.Id): `"$($c.Role)`",$nl"
}
$scriptJs += "};$nl$nl"

$scriptJs += "const characterElement = {$nl"
foreach ($c in $chars) {
  $scriptJs += "  $($c.Id): `"$($c.Element)`",$nl"
}
$scriptJs += "};$nl$nl"

$scriptJs += "const weaponNames = {$nl"
foreach ($c in $chars) {
  $scriptJs += "  $($c.Id): `"Staff of $($c.DisplayName)`",$nl"
}
$scriptJs += "};$nl$nl"

$scriptJs += "const skillData = {$nl"
foreach ($c in $chars) {
  $scriptJs += "  $($c.Id): {$nl"
  $scriptJs += "    origin: {$nl"
  $scriptJs += "      ultimate: { title: `"Ultimate: $($c.DisplayName)`", desc: `"Unleashes ultimate power.`", video: `"`" },$nl"
  $scriptJs += "      `"skill-2`": { title: `"Skill 2: $($c.DisplayName)`", desc: `"Second skill ability.`", video: `"`" },$nl"
  $scriptJs += "      `"skill-1`": { title: `"Skill 1: $($c.DisplayName)`", desc: `"First skill ability.`", video: `"`" }$nl"
  $scriptJs += "    },$nl"
  $scriptJs += "    character: {$nl"
  $scriptJs += "      ultimate: { title: `"Ultimate: $($c.DisplayName)`", desc: `"Unleashes ultimate power.`", video: `"`" },$nl"
  $scriptJs += "      `"skill-2`": { title: `"Skill 2: $($c.DisplayName)`", desc: `"Second skill ability.`", video: `"`" },$nl"
  $scriptJs += "      `"skill-1`": { title: `"Skill 1: $($c.DisplayName)`", desc: `"First skill ability.`", video: `"`" }$nl"
  $scriptJs += "    },$nl"
  $scriptJs += "    weapon: {$nl"
  $scriptJs += "      ultimate: { title: `"Ultimate: $($c.DisplayName)`", desc: `"Unleashes ultimate power.`", video: `"`" },$nl"
  $scriptJs += "      `"skill-2`": { title: `"Skill 2: $($c.DisplayName)`", desc: `"Second skill ability.`", video: `"`" },$nl"
  $scriptJs += "      `"skill-1`": { title: `"Skill 1: $($c.DisplayName)`", desc: `"First skill ability.`", video: `"`" }$nl"
  $scriptJs += "    }$nl"
  $scriptJs += "  },$nl"
}
$scriptJs += "};$nl"

$scriptJs | Out-File "D:\WEB\APK\script_new.js" -Encoding utf8 -Force

$avatarHtml = ""
foreach ($c in $chars) {
  $avatarHtml += "              <div class=`"avatar-item`" data-id=`"$($c.Id)`">$nl"
  $avatarHtml += "                <img class=`"avatar`" src=`"$($c.IconPath)`" alt=`"$($c.DisplayName)`">$nl"
  $avatarHtml += "                <div class=`"content`"><h1>$($c.DisplayName)</h1></div>$nl"
  $avatarHtml += "              </div>$nl"
}

$newIndexHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Arcanist - Character Showcase</title>
  <link rel="stylesheet" href="style.css" />
</head>
<body>

  <!-- SIDEBAR NAVIGATION -->
  <aside class="side-nav">
    <button class="nav-item active" data-role="huanglong" title="Huanglong">
      <div class="icon-wrapper">
        <img src="asset/role_huanglong.png" alt="Huanglong">
      </div>
      <span class="nav-label">Huanglong</span>
    </button>
    <button class="nav-item" data-role="role2" title="Role 2">
      <div class="icon-wrapper">
        <img src="asset/role2.png" alt="Role 2">
      </div>
      <span class="nav-label">Role 2</span>
    </button>
    <button class="nav-item" data-role="role3" title="Role 3">
      <div class="icon-wrapper">
        <img src="asset/role3.png" alt="Role 3">
      </div>
      <span class="nav-label">Role 3</span>
    </button>
    <button class="nav-item" data-role="role4" title="Role 4">
      <div class="icon-wrapper">
        <img src="asset/role4.png" alt="Role 4">
      </div>
      <span class="nav-label">Role 4</span>
    </button>
  </aside>

  <!-- MAIN CONTAINER -->
  <main class="hero">
    <canvas id="particleCanvas" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; z-index: 1;"></canvas>

    <!-- TOP HEADER -->
    <header class="hero-header" style="position: relative; z-index: 10;">
      <h1 class="logo-title">Arcanist</h1>
      <button class="btn-home">HOME</button>
    </header>

    <!-- CENTER CONTENT GRID -->
    <section class="hero-content" style="position: relative; z-index: 5;">

      <!-- LEFT COLUMN: INFO, QUOTE & SKILL PREVIEW -->
      <div class="column-left">
        <div class="char-details">
          <h2 class="char-name" id="charName">Vila</h2>
          <div class="meta-row">
            <div class="bpadges" id="charBadges"></div>
            <div class="stars" id="charStars">
              <img class="img-stars" src="asset/stars-6.png" alt="Rarity Stars">
            </div>
          </div>
          <div class="role-display">
            <span class="role-label">Role:</span>
            <span class="role-name" id="roleName">Nature DPS / Beastmaster</span>
          </div>
          <div class="element-display">
            <span class="element-label">Element:</span>
            <span class="element-name" id="elementName">Plant (Nature)</span>
          </div>
          <div class="weapon-display" id="weaponDisplay">
            <span class="weapon-label">Psychube:</span>
            <span class="weapon-name" id="weaponName">Staff of Wilderness</span>
          </div>
          <p class="char-quote" id="charQuote"></p>

          <!-- CHARACTER STATS -->
          <div class="char-stats">
            <div class="stat-item">
              <div class="stat-header">
                <span class="stat-label">HP</span>
                <span class="stat-value" id="stat-hp">100</span>
              </div>
              <div class="stat-bar">
                <div class="stat-fill" id="stat-fill-hp" style="width: 85%"></div>
              </div>
            </div>

            <div class="stat-item">
              <div class="stat-header">
                <span class="stat-label">ATK</span>
                <span class="stat-value" id="stat-atk">100</span>
              </div>
              <div class="stat-bar">
                <div class="stat-fill" id="stat-fill-atk" style="width: 80%"></div>
              </div>
            </div>

            <div class="stat-item">
              <div class="stat-header">
                <span class="stat-label">DEF</span>
                <span class="stat-value" id="stat-def">100</span>
              </div>
              <div class="stat-bar">
                <div class="stat-fill" id="stat-fill-def" style="width: 75%"></div>
              </div>
            </div>

            <div class="stat-item">
              <div class="stat-header">
                <span class="stat-label">CRIT</span>
                <span class="stat-value" id="stat-crit">100%</span>
              </div>
              <div class="stat-bar">
                <div class="stat-fill" id="stat-fill-crit" style="width: 60%"></div>
              </div>
            </div>

            <div class="stat-item">
              <div class="stat-header">
                <span class="stat-label">ENERGY</span>
                <span class="stat-value" id="stat-energy">100%</span>
              </div>
              <div class="stat-bar">
                <div class="stat-fill" id="stat-fill-energy" style="width: 70%"></div>
              </div>
            </div>
          </div>
        </div>

        <div class="skill-preview-container" id="skillPreview" style="cursor: pointer;" title="Click to enlarge">
          <video id="skillVideo" class="skill-media" autoplay muted loop playsinline preload="metadata" hidden></video>
          <div id="skillPreviewEmpty" class="skill-preview-empty" hidden><span>No Preview</span></div>
          <div class="skill-info-overlay" id="skillInfoOverlay">
            <h4 id="skillTitle">Ultimate Skill</h4>
            <p id="skillDesc">Unleash devastating power against enemies.</p>
          </div>
        </div>
      </div>

      <!-- CENTER COLUMN: HERO IMAGE & AVATARS -->
      <div class="center-container">
        <div class="hero-image-container">
          <img id="charImage" src="vila/vila_garment1.png" alt="Character Art">
        </div>
        <div class="wrapper">
          <div class="hero-avatars-wrapper">
            <button class="carousel-nav prev" aria-label="Previous">&lsaquo;</button>
            <div class="hero-avatars">
$avatarHtml
            </div>
            <button class="carousel-nav next" aria-label="Next">&rsaquo;</button>
          </div>
        </div>
      </div>

      <!-- RIGHT COLUMN: TABS & SKILLS -->
      <div class="column-right">
        <div class="tabs-container">
          <div class="tab-group category-tabs">
            <button class="tab-btn active" data-category="origin" aria-label="Origin Skin">
              <img src="vila/tabvila1.png" alt="Origin">
            </button>
            <button class="tab-btn" data-category="character" aria-label="Character Skin">
              <img src="vila/tabvila2.png" alt="Character">
            </button>
            <button class="tab-btn" data-category="weapon" aria-label="Weapon Skin">
              <img src="vila/tabvila3.png" alt="Weapon">
            </button>
          </div>

          <div class="tab-group skill-tabs">
            <button class="skill-btn active" data-skill="ultimate" aria-label="Ultimate Skill">
              <img id="skillIcon-ultimate" src="vila/vila-ulti.png" alt="Ultimate">
            </button>
            <button class="skill-btn" data-skill="skill-2" aria-label="Skill 2">
              <img id="skillIcon-skill-2" src="vila/vila-skill2.png" alt="Skill 2">
            </button>
            <button class="skill-btn" data-skill="skill-1" aria-label="Skill 1">
              <img id="skillIcon-skill-1" src="vila/vila-skill1.png" alt="Skill 1">
            </button>
          </div>
        </div>
      </div>

    </section>

  </main>

  <!-- FULLSCREEN MODAL -->
  <div class="skill-modal" id="skillModal">
    <div class="modal-content">
      <button class="modal-close" id="modalClose">&times;</button>
      <video id="modalVideo" class="modal-video" autoplay muted loop playsinline preload="metadata"></video>
      <div class="modal-info">
        <h2 id="modalTitle">Skill Name</h2>
        <p id="modalDesc">Skill description goes here.</p>
      </div>
    </div>
  </div>

  <script src="script.js"></script>
  <script src="app.js"></script>
</body>
</html>
"@

$newIndexHtml | Out-File "D:\WEB\APK\Index_new.html" -Encoding utf8 -Force

Write-Host "Generated Index_new.html and script_new.js successfully with $($chars.Count) characters."
