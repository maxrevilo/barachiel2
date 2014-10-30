xdescribe "User should't see the settings button in login screen:", ->
    
    #Page objects
    LoginForm = require("../page_objects/login_form.po.coffee")
    # SignupForm = require("../page_objects/signup_form.po.coffee")

    params = browser.params
    ptor = undefined
    
    #beforeEach ->

    it "Will start from begining in login screen", ->
        ptor = protractor.getInstance()
        ptor.addMockModule "httpBackendMock", require("../mocks/backend.coffee").httpBackendMock
        browser.get "http://localhost:8100/#/login"
        browser.executeScript 'window.localStorage.clear();'

    it "not be settings button", ->
        #Go to signup
        expect(browser.getLocationAbsUrl()).toMatch "/signup"
        signup_form = new SignupForm()

    it "Should move to login screen when the go to loggin button is pressed", ->
        signup_form.go_login()
        expect(browser.getLocationAbsUrl()).toMatch "/login"

    login_form = new LoginForm()
    it "Should consist of the 2 login fields", ->
        expect(ptor.isElementPresent(login_form.user_email)).toBe true
        expect(ptor.isElementPresent(login_form.user_password)).toBe true

    it "Should be able to allow login", ()->
        login_form.setEmail "valid@email.com"
        login_form.setPassword "123456"
        login_form.login()

    it "Should redirect to the radar screen", ->
        expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
