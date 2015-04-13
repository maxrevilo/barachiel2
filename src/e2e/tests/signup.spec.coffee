describe "New User enters to the App and signs up:", ->
    
    #Page objects
    SignupForm = require("../page_objects/signup_form.po.coffee")
    TutorialPage = require("../page_objects/tutorial_page.po.coffee")
    helper = require('./helper.coffee')

    id = Date.now().toString(36)

    #beforeEach ->

    it "Should automatically redirect to signup when location hash is empty", ->
        expect(browser.getLocationAbsUrl()).toMatch "/signup"

    signup_form = new SignupForm()
    it "Should consist of the 3 signup fields", ->
        expect(signup_form.user_name.isPresent()).toBe true
        expect(signup_form.user_email.isPresent()).toBe true
        expect(signup_form.user_password.isPresent()).toBe true

    it "Should be able to allow signup", ->
        signup_form.setName "TestUser-#{id}"
        signup_form.setEmail "valid#{id}@email.com"
        signup_form.setPassword "123456"
        signup_form.signup()

    tutorial_page = new TutorialPage()
    it "Should redirect to the tutorial", ->
        expect(browser.getLocationAbsUrl()).toMatch "/tutorial"
        expect(tutorial_page.title.isPresent()).toBe true
        helper.logout()
