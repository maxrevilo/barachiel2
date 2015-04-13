describe "User enters to the App and logs in with existing account:", ->
    
    #Page objects
    RadarTab = require("../page_objects/radar_tab.po.coffee")
    helper = require('./helper.coffee')
    
    #beforeEach ->

    it "Should automatically redirect to signup when location hash is empty", ->
        expect(browser.getLocationAbsUrl()).toMatch "/signup"
