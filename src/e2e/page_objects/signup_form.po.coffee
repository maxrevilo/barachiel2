SignupForm = ->
    @base = element(By.id("signupForm"))

    @user_name = @base.element(By.model("user.name"))
    @user_email = @base.element(By.model("user.email"))
    @user_password = @base.element(By.model("user.password"))

    @setName = (value) -> @user_name.sendKeys value

    @setEmail = (value) -> @user_email.sendKeys value

    @setPassword = (value) -> @user_password.sendKeys value

    @signup = -> element(By.id("signup")).click()

    @go_login = -> element(By.css('[ui-sref="st.login"]')).click()

    return

module.exports = SignupForm
