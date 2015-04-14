 module.exports =
    scrollTo: (filter) ->
        scrollIntoView = ->
          arguments[0].scrollIntoView()
        browser.executeScript(scrollIntoView, filter)
        
    clearAndSendKeys: (element, string) ->
        element.clear().then () ->
            element.sendKeys string

    login: (email, password) ->
        LoginForm = require("../page_objects/login_form.po.coffee")
        SignupForm = require("../page_objects/signup_form.po.coffee")
        signup_form = new SignupForm()
        login_form = new LoginForm()
        signup_form.go_login()
        this.clearAndSendKeys login_form.user_email, email
        this.clearAndSendKeys login_form.user_password, password
        login_form.login()
        return
        
    logout: ->
        ProfileTab = require("../page_objects/profile_tab.po.coffee")
        profile_tab = new ProfileTab()
        browser.setLocation 'tab/profile'
        filter = browser.findElement(By.id('logout_btn'))
        this.scrollTo(filter)
        profile_tab.logout()
        return
