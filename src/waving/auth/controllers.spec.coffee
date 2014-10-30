describe "Unit Testing Examples", ->
    beforeEach ->
        module "app"

    it "should pass", ->
        expect(true).toBe true