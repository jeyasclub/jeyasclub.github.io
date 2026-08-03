document.querySelectorAll("[data-slider]").forEach((slider) => {
  const track = slider.querySelector("[data-slider-track]");
  const slides = track ? Array.from(track.children) : [];
  const prev = slider.querySelector("[data-slider-prev]");
  const next = slider.querySelector("[data-slider-next]");
  const dotsWrap = slider.querySelector("[data-slider-dots]");
  if (!track || !slides.length || !prev || !next || !dotsWrap) return;
  let index = 0;
  slides.forEach((_, slideIndex) => {
    const dot = document.createElement("button");
    dot.type = "button";
    dot.className = "slider-dot";
    dot.setAttribute("aria-label", `Buka slide ${slideIndex + 1}`);
    dot.addEventListener("click", () => goTo(slideIndex));
    dotsWrap.appendChild(dot);
  });
  const dots = Array.from(dotsWrap.children);
  function goTo(nextIndex) {
    index = (nextIndex + slides.length) % slides.length;
    track.style.transform = `translateX(-${index * 100}%)`;
    dots.forEach((dot, dotIndex) => dot.classList.toggle("is-active", dotIndex === index));
  }
  prev.addEventListener("click", () => goTo(index - 1));
  next.addEventListener("click", () => goTo(index + 1));
  goTo(0);
});
