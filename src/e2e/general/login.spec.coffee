describe "User enters to the App and logs in with existing account:", ->
    
    #Page objects
    LoginForm = require("../page_objects/login_form.po.coffee")
    SignupForm = require("../page_objects/signup_form.po.coffee")
    AlertModal = require("../page_objects/alert_modal.po.coffee")
    helper = require('./helper.coffee')
    
    #beforeEach ->

    it "Should automatically redirect to signup when location hash is empty", ->
        expect(browser.getLocationAbsUrl()).toMatch "/signup"

    signup_form = new SignupForm()
    it "Should move to login screen when the go to loggin button is pressed", ->
        signup_form.go_login()
        expect(browser.getLocationAbsUrl()).toMatch "/login"

    login_form = new LoginForm()
    it "Should consist of the 2 login fields", ->
        expect(login_form.user_email.isPresent()).toBe true
        expect(login_form.user_password.isPresent()).toBe true

    alert_modal = new AlertModal()
    id = Date.now().toString(36)
    it "Should not allow login with an email that does not exist", -> 
        login_form.setEmail "#{id}@email.com" 
        login_form.setPassword browser.params.login.password 
        login_form.login()
        expect(alert_modal.ok_btn.isPresent()).toBe true
        alert_modal.close()

    it "Should not allow login with the wrong password", ->
        login_form.user_email.clear()
        .then () -> login_form.setEmail browser.params.login.email
        login_form.user_password.clear()
        .then () -> login_form.setPassword(browser.params.login.password + "a")
        login_form.login()
        expect(alert_modal.ok_btn.isPresent()).toBe true
        alert_modal.close()

    it "Should allow login with the right params", ->
        login_form.user_email.clear()
        .then () -> login_form.setEmail browser.params.login.email
        login_form.user_password.clear()
        .then () -> login_form.setPassword browser.params.login.password
        login_form.login()

    it "Should redirect the logged user to the radar screen", ->
        expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
        helper.logout()
