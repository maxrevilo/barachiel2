angular.module("barachiel", [
        "barachiel.config"
        "ionic"
        "underscore"
        "pascalprecht.translate"
        "barachiel.util.services"
        "barachiel.device.services"
        "barachiel.auth.services"
        "barachiel.auth.controllers"
        "barachiel.directives"
        "barachiel.controllers"
        "barachiel.services"
    ])
    .run(($ionicPlatform, $rootScope, $state, AuthService) ->
        $ionicPlatform.ready ->
            console.log "Barachiel running on #{window.platform_service_definition.name}"

            # Hide the accessory bar by default (remove this to show the accessory
            # bar above the keyboard for form inputs)
            if window.cordova and window.cordova.plugins.Keyboard
                cordova.plugins.Keyboard.hideKeyboardAccessoryBar true
            # org.apache.cordova.statusbar required
            StatusBar.styleDefault() if window.StatusBar

            if AuthService.state_requires_auth($state.current) and not AuthService.isAuthenticated(true)
                $state.transitionTo "signup"

            $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
                if AuthService.state_requires_auth(toState) and not AuthService.isAuthenticated()
                    # User isn’t authenticated
                    $state.transitionTo "signup"
                    event.preventDefault()
                return
    )
    .config(($stateProvider, $urlRouterProvider, $translateProvider, $httpProvider) ->

        ####### Interceptors ########
        $httpProvider.interceptors.push('authHttpResponseInterceptor');

        ####### Routing ########

        $stateProvider
            .state("login",
                url: "/login"
                templateUrl: "templates/login.html"
                controller: "LoginCtrl"
                authenticate: false
            )
            .state("signup",
                url: "/signup"
                templateUrl: "templates/signup.html"
                controller: "SignupCtrl"
                authenticate: false
            )
            .state("forgot_password",
                url: "/forgot_password"
                templateUrl: "templates/forgot_password.html"
                controller: "ForgotPasswordCtrl"
                authenticate: false
            )
            .state("tutorial",
                url: "/tutorial"
                templateUrl: "templates/tutorial.html"
                controller: "TutorialCtrl"
                authenticate: false
            )
            .state("tab",
                url: "/tab"
                abstract: true
                templateUrl: "templates/tabs.html"
                controller: 'TabCtrl'
            )
            .state("tab.radar",
                url: "/radar"
                #authenticate undefined is equivalent to authenticate = true.
                views:
                    "tab-radar":
                        templateUrl: "templates/tab-radar.html"
                        controller: "RadarCtrl"
            )
            .state("tab.radar-user-detail",
                url: "/radar/user/:userId"
                views:
                    "tab-radar":
                        templateUrl: "templates/user-detail.html"
                        controller: "UserDetailCtrl"
            )
            .state("tab.wavers",
                url: "/wavers"
                views:
                    "tab-wavers":
                        templateUrl: "templates/tab-wavers.html"
                        controller: "WaversCtrl"
            )
            .state("tab.waver-detail",
                url: "/waver/:waverId"
                views:
                    "tab-wavers":
                        templateUrl: "templates/waver-detail.html"
                        controller: "WaverDetailCtrl"
            )
            .state("tab.waver-user-detail",
                url: "/waver/user/:userId"
                views:
                    "tab-wavers":
                        templateUrl: "templates/user-detail.html"
                        controller: "UserDetailCtrl"
            )
            .state("tab.profile",
                url: "/profile"
                views:
                    "tab-profile":
                        templateUrl: "templates/tab-profile.html"
                        controller: "ProfileCtrl"
            )

        # if none of the above states are matched, use this as the fallback
        $urlRouterProvider.otherwise "/tab/radar"

        ####### Internationalization ########
        $translateProvider
            .useStaticFilesLoader(
                prefix: '/localizations/'
                suffix: '.json'
            )
            .registerAvailableLanguageKeys(['en', 'es'],
                'en_US': 'en',
                'en_UK': 'en',
                'es': 'es',
            )
            .fallbackLanguage('en')
            .determinePreferredLanguage()
    )
