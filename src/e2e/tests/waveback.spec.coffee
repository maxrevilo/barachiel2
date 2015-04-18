describe "User enters to the App and waves back to an existing user:", ->
    
    #Page objects
    WaveDetail = require("../page_objects/wave_detail.po.coffee")
    WaversTab = require("../page_objects/wavers_tab.po.coffee")
    RadarUserProfile = require("../page_objects/radar_user_profile.po.coffee")
    helper = require('./helper.coffee')
    
    #beforeEach ->


    it "Should redirect to the radar tab after login", ->
        helper.login browser.params.waveback.liked_email, browser.params.waveback.password
        expect(browser.getLocationAbsUrl()).toMatch "/tab/radar"
   
    wavers_tab = new WaversTab()
    it "Should show a wave from another user", ->
        browser.setLocation('/tab/wavers')
        expect(wavers_tab.wavers_list.count()).toEqual 1
        
    wave_detail = new WaveDetail()
    it "Should see the wave notification", ->
        wavers_tab.wavers_list.first().click()
        expect(wave_detail.base.isPresent()).toBe true

    user_profile = new RadarUserProfile()
    it "Should be able to wave back", ->
        wave_detail.see_profile()
        user_profile.send_wave()
        expect(user_profile.whitdraw_btn.isPresent()).toBe true
        helper.logout()

    it "The waved back user should see a wave from the first user", ->
        helper.login browser.params.waveback.liker_email, browser.params.waveback.password
        browser.setLocation('/tab/wavers')
        expect(wavers_tab.wavers_list.count()).toEqual 1
        helper.logout()
