describe "User enters to the App and logs in with existing account:", ->
    
    #Page objects
    LoginForm = require("../page_objects/login_form.po.coffee")
    SignupForm = require("../page_objects/signup_form.po.coffee")
    
    #beforeEach ->

    it "Should automatically redirect to login when location hash is empty", ->
        expect(browser.getLocationAbsUrl()).toMatch "/signup"
        # browser.sleep(50000000);

    signup_form = new SignupForm()
    it "Should move to login screen when the go to loggin button is pressed", ->
        signup_form.go_login()
        expect(browser.getLocationAbsUrl()).toMatch "/login"

    login_form = new LoginForm()
    it "Should consist of the 2 login fields", ->
        expect(login_form.user_email.isPresent()).toBe true
        expect(login_form.user_password.isPresent()).toBe true

    #it "Should not allow login with an email that does not exist", -> 

    #it "Should not allow login with the wrong password" ->

    it "Should allow login with the right params", ->
        #browser.pause()
        
        login_form.user_email.sendKeys browser.params.login.email
        #browser.pause()
        #login_form.setPassword browser.params.login.password 
        #browser.pause()
        #login_form.login()

    #it "Should redirect to the radar screen", ->
        #expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
        #browser.get "http://localhost:8100/#/tab/profile"

    #describe "Logged user should have a session", ->

        #it "reload the page", ->
            #browser.get "http://localhost:8100"
            #browser.refresh()

        #it "should redirect to radar screen", ->
            #expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
