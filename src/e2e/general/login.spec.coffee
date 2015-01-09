base_describe "User enters to the App and logs in with existing account:", (ptor, params)->
    
    #Page objects
    LoginForm = require("../page_objects/login_form.po.coffee")
    SignupForm = require("../page_objects/signup_form.po.coffee")
    
    #beforeEach ->

    it "Should automatically redirect to login when location hash is empty", ->
        expect(browser.getLocationAbsUrl()).toMatch "/signup"
        # ptor.sleep(50000000);

    signup_form = new SignupForm()
    it "Should move to login screen when the go to loggin button is pressed", ->
        signup_form.go_login()
        expect(browser.getLocationAbsUrl()).toMatch "/login"

    login_form = new LoginForm()
    it "Should consist of the 2 login fields", ->
        expect(ptor.isElementPresent(login_form.user_email)).toBe true
        expect(ptor.isElementPresent(login_form.user_password)).toBe true

    it "Should be able to allow login", ->
        login_form.setEmail "test1@t.com"
        login_form.setPassword "1234"
        login_form.login()

    it "Should redirect to the radar screen", ->
        expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
        browser.get "http://localhost:8100/#/tab/profile"

    describe "Logged user should have a session", ->

        it "reload the page", ->
            browser.get "http://localhost:8100"
            ptor.refresh()

        it "should redirect to radar screen", ->
            expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"