RadarUserProfile = (email) ->
    By.addLocator 'detailEmail', (email, opt_parentElement, opt_rootSelector) ->
        using = if opt_parentElement then opt_parentElement else document
        items = using.querySelectorAll('#user-detail')
        Array.prototype.filter.call items, (item) ->
            email_field = item.querySelector('label[ng-if="user.email"] .content')
            if email_field
                email_field.textContent is email
            else
                false
    
    @base = if email then element(By.detailEmail(email)) else element(By.id("user-detail"))

    @wave_btn = @base.element(By.css("#send_wave_btn.button-calm"))
    @whitdraw_btn = @base.element(By.css("#send_wave_btn.button-assertive"))

    @send_wave = -> @wave_btn.click()
    @whitdraw_wave = -> @whitdraw_btn.click()

    return

module.exports = RadarUserProfile

