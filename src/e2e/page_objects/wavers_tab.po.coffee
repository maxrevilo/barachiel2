WaversTab = ->
    @base = element(By.id("tab-wavers"))

    @wavers_list = @base.all(By.css("yg-waver-item"))

    return

module.exports = WaversTab
