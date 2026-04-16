let RecaptchaV3 = {
  mounted() {
    let form = this.el
    const siteKey = form.dataset.recaptchaSiteKey

    if (!siteKey) {
      console.error("RecaptchaV3: missing data-recaptcha-site-key on form")
      return
    }

    form.addEventListener("submit", (e) => {
      let token_input = document.getElementById("recaptcha_token")
      if (token_input.value == "") {
        e.stopPropagation()
        e.preventDefault()
        grecaptcha.ready(() => {
          grecaptcha.execute(siteKey, {action: "booking"}).then((token) => {
            token_input.value = token
            form.dispatchEvent(new Event("submit", {bubbles: true}))
          })
        })
      }
    })
  }
}

export default RecaptchaV3
