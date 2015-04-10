AlertModal = ->
    @base = element(By.css(".popup-container.popup-showing.active"))

    @box = @base.element(By.css(".popup"))
    @ok_btn = @base.element(By.buttonText('OK'))

    @close = -> @ok_btn.click()

    return

module.exports = AlertModal
