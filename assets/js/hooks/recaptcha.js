let RecaptchaV3 = {
  mounted() {
    let form = this.el
    const siteKey = form.dataset.recaptchaSiteKey

    if (!siteKey) {
      console.error("RecaptchaV3: missing data-recaptcha-site-key on form")
      return
    }

    let executing = false

    form.addEventListener("submit", (e) => {
      const token_input = document.getElementById("recaptcha_token")
      if (!token_input) return

      if (token_input.value !== "") {
        return
      }

      if (executing) {
        e.preventDefault()
        e.stopPropagation()
        return
      }

      e.preventDefault()
      e.stopPropagation()
      executing = true

      grecaptcha.ready(() => {
        grecaptcha
          .execute(siteKey, {action: "booking"})
          .then((token) => {
            token_input.value = token
            executing = false
            if (typeof form.requestSubmit === "function") {
              form.requestSubmit()
            } else {
              form.dispatchEvent(new Event("submit", {bubbles: true, cancelable: true}))
            }
          })
          .catch((err) => {
            executing = false
            console.error("RecaptchaV3: execute failed", err)
          })
      })
    })
  }
}

export default RecaptchaV3
