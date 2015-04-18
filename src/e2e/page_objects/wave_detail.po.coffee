WaveDetail = ->
    @base = element(By.id("wave-detail"))

    @see_profile_btn = @base.all(By.css(".button-large.button-clear"))
    
    @see_profile = -> @see_profile_btn.click()
    return

module.exports = WaveDetail
