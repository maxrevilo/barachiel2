RadarTab = ->
    By.addLocator 'userItemText', (text, opt_parentElement, opt_rootSelector) ->
        using = opt_parentElement
        items = using.querySelectorAll('yg-user-item > h2')
        Array.prototype.filter.call items, (item) ->
             item.textContent is text

    @base = element(By.id("tab-radar"))

    @wavers_list = @base.all(By.css("yg-user-item"))

    @get_user_by_name = (name) -> @base.element(By.userItemText name)

    return

module.exports = RadarTab
