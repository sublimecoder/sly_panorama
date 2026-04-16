let RecaptchaV3 = {
  mounted() {
    console.log("mounted")
    let form = this.el
    form.addEventListener("submit", (e) => {
      token_input = document.getElementById("recaptcha_token")
      if (token_input.value == "") {
        e.stopPropagation()
        e.preventDefault()
        grecaptcha.ready(() => {
          grecaptcha.execute("6LfEiLYrAAAAAHBdgOM6i0jAzmKD5if255EwfRox", {action: "booking"}).then((token) => {
            token_input.value = token
            console.log("Recaptcha set")
            form.dispatchEvent(
              new Event("submit", {bubbles: true})
            )
          })
        })
      }
    })
  }
}

export default RecaptchaV3
