ProfileTab = ->
    @base = element(By.id("profile-view"))

    @logout_btn = @base.element(By.id("logout_btn"))
    @logout = -> @logout_btn.click()

    return

module.exports = ProfileTab
