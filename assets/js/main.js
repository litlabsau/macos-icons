document.addEventListener("DOMContentLoaded", () => {
  const cards = document.querySelectorAll(".icon-card");

  // Copy each icon's URL to the clipboard
  cards.forEach((card) => {
    const btn = card.querySelector(".copy-btn");
    btn.addEventListener("click", async () => {
      try {
        await navigator.clipboard.writeText(card.dataset.url);
        const label = btn.textContent;
        btn.textContent = "Copied!";
        btn.classList.add("btn-success");
        setTimeout(() => {
          btn.textContent = label;
          btn.classList.remove("btn-success");
        }, 1200);
      } catch (err) {
        console.error("Copy failed:", err);
      }
    });
  });

  // Live search filter
  const search = document.getElementById("search");
  search.addEventListener("input", () => {
    const q = search.value.trim().toLowerCase();
    cards.forEach((card) => {
      const match = card.dataset.name.toLowerCase().includes(q);
      card.closest(".col").classList.toggle("d-none", !match);
    });
  });
});
