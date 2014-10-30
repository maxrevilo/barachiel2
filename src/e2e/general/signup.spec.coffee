base_describe "New User enters to the App and signs up:", (ptor, params)->

    #Page objects
    SignupForm = require("../page_objects/signup_form.po.coffee")

    #beforeEach ->

    it "Should automatically redirect to signup when location hash is empty", ->
        expect(browser.getLocationAbsUrl()).toMatch "/signup"

    signup_form = new SignupForm()
    it "Should consist of the 3 signup fields", ->
        expect(ptor.isElementPresent(signup_form.user_name)).toBe true
        expect(ptor.isElementPresent(signup_form.user_email)).toBe true
        expect(ptor.isElementPresent(signup_form.user_password)).toBe true

    it "Should be able to allow signup", ->
        signup_form.setName "New User Test"
        signup_form.setEmail "valid@email.com"
        signup_form.setPassword "123456"
        signup_form.signup()

    it "Should redirect to the tutorial", ->
        expect(browser.getLocationAbsUrl()).toMatch "/tutorial"
