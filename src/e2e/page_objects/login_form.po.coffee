LoginForm = ->
    @base = element(By.id("loginForm"))

    @user_email = @base.element(By.model("user.email"))
    @user_password = @base.element(By.model("user.password"))

    @setEmail = (value) -> @user_email.sendKeys value

    @setPassword = (value) -> @user_password.sendKeys value

    @login = -> element(By.id("login")).click()

    return

module.exports = LoginForm
