describe "User enters to the App and logs in with existing account:", ->
    
    #Page objects
    RadarTab = require("../page_objects/radar_tab.po.coffee")
    WaversTab = require("../page_objects/wavers_tab.po.coffee")
    RadarUserProfile = require("../page_objects/radar_user_profile.po.coffee")
    helper = require('./helper.coffee')
    
    #beforeEach ->


    it "Should redirect to the radar tab after login", ->
        helper.login browser.params.wave.email, browser.params.wave.password
        expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
   
    radar_tab = new RadarTab()
    it "Should show all the nearby wavers", ->
        expect(radar_tab.wavers_list.count()).toEqual 5

    user_profile = new RadarUserProfile()
    it "Should be able to send a wave to a nearby user", ->
        radar_tab.get_user_by_name(browser.params.wave.waved_name).click()
        user_profile.send_wave()
        expect(user_profile.whitdraw_btn.isPresent()).toBe true
        helper.logout()

    wavers_tab = new WaversTab()
    it "The waved user should see a wave from the first user", ->
        helper.login browser.params.wave.waved_email, browser.params.wave.waved_password
        expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
        browser.setLocation('/tab/wavers')
        expect(wavers_tab.wavers_list.count()).toEqual 1
        helper.logout()

    it "Should be able to whitdraw a wave", ->
        helper.login browser.params.wave.email, browser.params.wave.password
        radar_tab.get_user_by_name(browser.params.wave.waved_name).click()
        user_profile.whitdraw_wave()
        alertDialog = browser.switchTo().alert()
        alertDialog.accept()
        expect(user_profile.wave_btn.isPresent()).toBe true
        helper.logout()

    it "The waved user that had the wave whitdrawed, should not see a the wave", ->
        helper.login browser.params.wave.waved_email, browser.params.wave.waved_password
        expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
        browser.setLocation('/tab/wavers')
        expect(wavers_tab.wavers_list.count()).toEqual 0
        helper.logout()
