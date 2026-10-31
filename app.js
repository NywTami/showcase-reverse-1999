const categories = {
  origin: originData,
  character: characterData,
  weapon: weaponData
};
const skills = ["ultimate", "skill-2", "skill-1"];
const gradients = {
  Beast: "linear-gradient(135deg, #3a2b1b 0%, #6b4a2a 100%)",
  Plant: "linear-gradient(135deg, #1b2e1f 0%, #2a4a30 100%)",
  Star: "linear-gradient(135deg, #2b2b3a 0%, #4a4a6b 100%)",
  Mineral: "linear-gradient(135deg, #3a2528 0%, #68434a 100%)",
  Intellect: "linear-gradient(135deg, #39311b 0%, #68572a 100%)",
  Spirit: "linear-gradient(135deg, #30233a 0%, #59406b 100%)"
};

const hero = document.querySelector(".hero");
const avatarsContainer = document.querySelector(".hero-avatars");
const avatarItems = [];
const tabButtons = [...document.querySelectorAll(".tab-btn")];
const skillButtons = [...document.querySelectorAll(".skill-btn")];
const skillVideo = document.getElementById("skillVideo");
const skillPreviewEmpty = document.getElementById("skillPreviewEmpty");
const skillModal = document.getElementById("skillModal");
const modalVideo = document.getElementById("modalVideo");
const previousButton = document.querySelector(".carousel-nav.prev");
const nextButton = document.querySelector(".carousel-nav.next");
let currentCharId = Object.keys(originData)[0];
let activeCategory = "origin";
let activeSkill = "ultimate";

function setText(id, value) {
  const element = document.getElementById(id);
  if (element) element.textContent = value;
}

function setActiveTab(category) {
  activeCategory = category;
  tabButtons.forEach((button) => {
    button.classList.toggle("active", button.dataset.category === category);
  });
}

function setActiveSkill(skill) {
  activeSkill = skill;
  skillButtons.forEach((button) => {
    button.classList.toggle("active", button.dataset.skill === skill);
  });
}

function updateStats(id) {
  const stats = characterStats[id];
  if (!stats) return;

  const values = [
    ["hp", stats.hp, 1000, 1900],
    ["atk", stats.atk, 200, 600],
    ["def", stats.def, 100, 300],
    ["crit", stats.crit, 10, 40],
    ["energy", stats.energy, 0, 100]
  ];

  values.forEach(([name, value, minimum, maximum]) => {
    const percent = Math.max(0, Math.min(100, ((value - minimum) / (maximum - minimum)) * 100));
    setText(`stat-${name}`, `${value}${name === "crit" || name === "energy" ? "%" : ""}`);
    const fill = document.getElementById(`stat-fill-${name}`);
    if (fill) fill.style.width = `${percent}%`;
  });
}

function updateBackground(id) {
  const element = (characterElement[id] || "Star").split(" ")[0];
  hero.style.setProperty("--bg-gradient", gradients[element] || gradients.Star);
}

function renderCharacter(id) {
  const data = categories[activeCategory]?.[id];
  if (!data) return;

  currentCharId = String(id);
  setText("charName", data.name);
  setText("charQuote", data.quote);

  const image = document.getElementById("charImage");
  image.src = data.image;
  image.alt = `${data.name} character art`;

  setText("roleName", characterRoles[id] || "Unknown");
  setText("elementName", characterElement[id] || "Unknown");
  setText("weaponName", weaponNames[id] || "Unknown");

  const badgeContainer = document.getElementById("charBadges");
  badgeContainer.replaceChildren();
  (data.badges || []).forEach((badge) => {
    const wrapper = document.createElement("span");
    wrapper.className = "badge";
    const availableIcons = ["Beast_Icon.png", "Plant_Icon.png", "Star_Icon.png", "Mineral_Icon.png", "Intellect_Icon.png", "Spirit_Icon.png"];
    const iconName = badge.icon.split("/").pop();
    if (availableIcons.includes(iconName)) {
      const icon = document.createElement("img");
      icon.src = badge.icon;
      icon.alt = "";
      wrapper.appendChild(icon);
    }
    const label = document.createElement("span");
    label.textContent = badge.text;
    wrapper.appendChild(label);
    badgeContainer.appendChild(wrapper);
  });

  tabButtons.forEach((button) => {
    const tabData = categories[button.dataset.category]?.[id];
    const tabImage = button.querySelector("img");
    if (tabData?.tabimage && tabImage) tabImage.src = tabData.tabimage;
  });

  updateStats(id);
  updateBackground(id);
  renderSkills();
}

function getCurrentSkill() {
  return skillData[currentCharId]?.[activeCategory]?.[activeSkill];
}

function closeSkillModal() {
  skillModal.classList.remove("active");
  modalVideo.pause();
  modalVideo.removeAttribute("src");
  modalVideo.load();
}

function renderSkills() {
  const skillSet = skillData[currentCharId]?.[activeCategory] || {};
  skillButtons.forEach((button) => {
    const skill = skillSet[button.dataset.skill];
    const icon = button.querySelector("img");
    if (icon) icon.hidden = !skill?.icon;
    if (skill?.icon && icon) icon.src = skill.icon;
  });

  const skill = getCurrentSkill();
  const videoPath = skill?.video;
  skillVideo.pause();
  skillVideo.removeAttribute("src");
  skillVideo.hidden = true;
  skillPreviewEmpty.hidden = Boolean(videoPath);
  setText("skillTitle", skill?.title || "Skill Preview");
  setText("skillDesc", skill?.desc || "No preview available.");

  if (videoPath) {
    skillVideo.src = videoPath;
    skillVideo.hidden = false;
    skillVideo.load();
    skillVideo.play().catch(() => {});
  }
}

function selectCharacter(id) {
  if (!categories.origin[id]) return;
  renderCharacter(id);
  avatarItems.forEach((avatar) => {
    avatar.classList.toggle("active", avatar.dataset.id === String(id));
  });
}

function applyFilter(filter) {
  const matching = [];
  avatarItems.forEach((avatar) => {
    const id = avatar.dataset.id;
    const visible = filter === "All" || (characterElement[id] || "").startsWith(filter);
    avatar.classList.toggle("hidden", !visible);
    if (visible) matching.push(id);
  });

  if (!matching.includes(currentCharId) && matching.length) {
    selectCharacter(matching[0]);
  }
  avatarsContainer.scrollTo({ left: 0, behavior: "smooth" });
}

function buildAvatars() {
  document.querySelectorAll(".avatar-item").forEach((avatar) => avatar.remove());
  avatarsContainer.replaceChildren();
  Object.entries(originData).forEach(([id, data]) => {
    const avatar = document.createElement("div");
    avatar.className = "avatar-item";
    avatar.dataset.id = id;
    avatar.setAttribute("role", "button");
    avatar.tabIndex = 0;
    avatar.setAttribute("aria-label", `Show ${data.name}`);

    const image = document.createElement("img");
    image.className = "avatar";
    image.src = data.tabimage || data.image;
    image.alt = "";

    const content = document.createElement("div");
    content.className = "content";
    const name = document.createElement("h1");
    name.textContent = data.name;
    content.appendChild(name);
    avatar.append(image, content);
    avatarsContainer.appendChild(avatar);
    avatarItems.push(avatar);
    avatar.addEventListener("click", () => selectCharacter(id));
    avatar.addEventListener("keydown", (event) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        selectCharacter(id);
      }
    });
  });
}

buildAvatars();
selectCharacter(currentCharId);

document.querySelectorAll(".nav-item").forEach((button) => {
  button.addEventListener("click", () => {
    document.querySelector(".nav-item.active")?.classList.remove("active");
    button.classList.add("active");
    applyFilter(button.dataset.afflatus || "All");
  });
});

tabButtons.forEach((button) => {
  button.addEventListener("click", () => {
    setActiveTab(button.dataset.category);
    renderCharacter(currentCharId);
  });
});

skillButtons.forEach((button) => {
  button.addEventListener("click", () => {
    setActiveSkill(button.dataset.skill);
    renderSkills();
  });
});

document.querySelector(".carousel-nav.prev")?.addEventListener("click", () => {
  avatarsContainer.scrollBy({ left: -230, behavior: "smooth" });
});
document.querySelector(".carousel-nav.next")?.addEventListener("click", () => {
  avatarsContainer.scrollBy({ left: 230, behavior: "smooth" });
});

function updateCarouselButtons() {
  previousButton.disabled = avatarsContainer.scrollLeft <= 5;
  nextButton.disabled =
    avatarsContainer.scrollLeft + avatarsContainer.clientWidth >=
    avatarsContainer.scrollWidth - 5;
}

avatarsContainer.addEventListener("scroll", updateCarouselButtons);
window.addEventListener("resize", updateCarouselButtons);
updateCarouselButtons();

function openSkillModal() {
  const skill = getCurrentSkill();
  if (!skill?.video) return;
  modalVideo.src = skill.video;
  setText("modalTitle", skill.title);
  setText("modalDesc", skill.desc);
  skillModal.classList.add("active");
  modalVideo.load();
  modalVideo.play().catch(() => {});
}

document.getElementById("skillPreview").addEventListener("click", openSkillModal);
document.getElementById("modalClose").addEventListener("click", closeSkillModal);
skillModal.addEventListener("click", (event) => {
  if (event.target === skillModal) closeSkillModal();
});
document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && skillModal.classList.contains("active")) {
    closeSkillModal();
  }
});

document.querySelector(".btn-home").addEventListener("click", () => {
  const allButton = document.querySelector('.nav-item[data-afflatus="All"]');
  allButton?.click();
  selectCharacter(Object.keys(originData)[0]);
  setActiveTab("origin");
  setActiveSkill("ultimate");
});

const heroImageContainer = document.querySelector(".hero-image-container");
const heroImage = document.getElementById("charImage");
heroImageContainer.addEventListener("mousemove", (event) => {
  const rect = heroImageContainer.getBoundingClientRect();
  const rotateX = ((event.clientY - rect.top - rect.height / 2) / rect.height) * -10;
  const rotateY = ((event.clientX - rect.left - rect.width / 2) / rect.width) * 10;
  heroImage.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.05, 1.05, 1.05)`;
});
heroImageContainer.addEventListener("mouseleave", () => {
  heroImage.style.transform = "";
});

const canvas = document.getElementById("particleCanvas");
const context = canvas.getContext("2d");
const particleColors = {
  Beast: ["#fb923c", "#f97316", "#fdba74"],
  Plant: ["#4ade80", "#22c55e", "#86efac"],
  Star: ["#a78bfa", "#8b5cf6", "#c4b5fd"],
  Mineral: ["#f87171", "#dc505c", "#fca5a5"],
  Intellect: ["#fbbf24", "#d99b18", "#fde68a"],
  Spirit: ["#c084fc", "#9333ea", "#d8b4fe"]
};
const particles = [];

function resizeCanvas() {
  canvas.width = canvas.clientWidth;
  canvas.height = canvas.clientHeight;
}

resizeCanvas();
window.addEventListener("resize", resizeCanvas);
for (let index = 0; index < 60; index += 1) {
  particles.push({
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    dx: (Math.random() - 0.5) * 0.5,
    dy: (Math.random() - 0.5) * 0.5,
    radius: Math.random() * 2 + 1,
    colorIndex: Math.floor(Math.random() * 3),
    opacity: Math.random() * 0.5 + 0.2
  });
}

function animateParticles() {
  const element = (characterElement[currentCharId] || "Star").split(" ")[0];
  const colors = particleColors[element] || particleColors.Star;
  context.clearRect(0, 0, canvas.width, canvas.height);
  particles.forEach((particle) => {
    particle.x += particle.dx;
    particle.y += particle.dy;
    if (particle.x < 0 || particle.x > canvas.width) particle.dx *= -1;
    if (particle.y < 0 || particle.y > canvas.height) particle.dy *= -1;
    context.globalAlpha = particle.opacity;
    context.fillStyle = colors[particle.colorIndex % colors.length];
    context.beginPath();
    context.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2);
    context.fill();
  });
  context.globalAlpha = 1;
  requestAnimationFrame(animateParticles);
}

animateParticles();
