module.exports = function(config){
    config.set({

        basePath : './',

        files : [
            'www/lib/angular/angular.js',
            'www/lib/angular-ui-router/release/angular-ui-router.js',
            'www/lib/angular-mocks/angular-mocks.js',
            //'www/js/*.js',
            //'www/**/**/**/*.spec.js',
            'www/js/*.js',
            'src/**/*.spec.js',
        ],

        reporters: ['progress', 'junit', 'coverage'],

        preprocessors: {
            'www/js/*.js': ['coverage']
        },

        autoWatch : true,

        frameworks: ['jasmine'],

        browsers : ['PhantomJS'],

        /*plugins : [
                    'karma-chrome-launcher',
                    'karma-firefox-launcher',
                    'karma-jasmine',
                    'karma-junit-reporter',
                    'karma-coverage',
                    ],*/

        junitReporter : {
            outputFile: 'test_reports/unit.xml',
            suite: 'unit'
        },
        coverageReporter: {
            type : 'html',
            dir : 'test_reports/coverage'
        }

    });
};