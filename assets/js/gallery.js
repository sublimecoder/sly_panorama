function initGallery(root) {
  const raw = root.dataset.galleryImages
  if (!raw) return

  let images
  try {
    images = JSON.parse(raw)
  } catch {
    return
  }

  if (!Array.isArray(images) || images.length === 0) return

  const lightbox = document.getElementById("lightbox")
  const lightboxImg = document.getElementById("lightbox-img")
  const closeBtn = document.getElementById("close-lightbox")
  const prevBtn = document.getElementById("prev-btn")
  const nextBtn = document.getElementById("next-btn")

  if (!lightbox || !lightboxImg || !closeBtn || !prevBtn || !nextBtn) {
    return
  }

  let currentIndex = 0

  function openModal(index) {
    currentIndex = index
    const item = images[index]
    lightboxImg.src = item.src
    lightboxImg.alt = item.title
    lightbox.classList.remove("hidden")
  }

  function closeModal() {
    lightbox.classList.add("hidden")
  }

  function showPrev() {
    currentIndex = currentIndex === 0 ? images.length - 1 : currentIndex - 1
    openModal(currentIndex)
  }

  function showNext() {
    currentIndex = currentIndex === images.length - 1 ? 0 : currentIndex + 1
    openModal(currentIndex)
  }

  root.querySelectorAll("[data-gallery-item]").forEach((el, idx) => {
    el.addEventListener("click", () => openModal(idx))
  })

  closeBtn.addEventListener("click", closeModal)
  prevBtn.addEventListener("click", showPrev)
  nextBtn.addEventListener("click", showNext)

  document.addEventListener("keydown", e => {
    if (lightbox.classList.contains("hidden")) return
    if (e.key === "Escape") closeModal()
    if (e.key === "ArrowLeft") showPrev()
    if (e.key === "ArrowRight") showNext()
  })

  lightbox.addEventListener("click", e => {
    if (!e.target.closest(".lightbox-content")) closeModal()
  })
}

export function mountGallery() {
  document.querySelectorAll("[data-gallery-images]").forEach(initGallery)
}
