 module.exports = 
    scrollTo: (filter) ->
        scrollIntoView = -> 
          arguments[0].scrollIntoView()
        browser.executeScript(scrollIntoView, filter);
        
    logout: ->
        ProfileTab = require("../page_objects/profile_tab.po.coffee")
        profile_tab = new ProfileTab()
        browser.setLocation 'tab/profile'
        filter = browser.findElement(By.id('logout_btn'))
        this.scrollTo(filter)
        profile_tab.logout()
        return
