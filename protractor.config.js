exports.config = {
    capabilities: {
        'browserName': 'chrome',
        'chromeOptions': {
            args: ['--disable-web-security']
        }
    },
    specs: [
        'src/e2e/**/*.spec.coffee'
    ],
    jasmineNodeOpts: {
        showColors: true,
        // defaultTimeoutInterval: 30000,
        defaultTimeoutInterval: 1800000,
        isVerbose: true,
    },
    // allScriptsTimeout: 20000,
    allScriptsTimeout: 1800000,
    onPrepare: function(){
        browser.driver.get('http://localhost:8100');
        ptor = protractor.getInstance();
        params = browser.params;

        afterEach(function () {
            browser.manage().logs().get('browser').then(function(browserLogs) {
                browserLogs.forEach(function(log){
                    if (log.level.value > 900) {
                        console.error(log.message);
                    } else {
                        console.log(log.message);
                    }
                });
            });
        });

        base_describe = function(text, callback) {
            describe(text, function() {
                it("Will start from begining", function() {
                    ptor.ignoreSynchronization = false; 
                    browser.addMockModule('barachiel.config', function () {
                        var module = angular.module('barachiel.config').config(function($provide) {
                            $provide.constant('BASE_URL', 'http://localhost:8000');
                        });
                    });

                    browser.get("http://localhost:8100");
                    browser.executeScript('window.sessionStorage.clear();');
                    browser.executeScript('window.localStorage.clear();');
                    ptor.refresh();

                    
                });

                callback(ptor, params);
            });
        };
    },
};