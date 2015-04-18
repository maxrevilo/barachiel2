RadarUserTab = () ->
    By.addLocator 'detailEmail', (email, opt_parentElement, opt_rootSelector) ->
        using = opt_parentElement
        items = using.querySelectorAll('user-detail')
        Array.prototype.filter.call items, (item) ->
             item.querySelector('label[ng-if="user.email"] .content').textContent is email

    @base = element(By.id("user-detail"))

    @wave_btn = @base.element(By.css("#send_wave_btn.button-calm"))
    @whitdraw_btn = @base.element(By.css("#send_wave_btn.button-assertive"))

    @send_wave = -> @wave_btn.click()
    @whitdraw_wave = -> @whitdraw_btn.click()

    return

module.exports = RadarUserTab

