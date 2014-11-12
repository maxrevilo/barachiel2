angular.module("barachiel", [
        "barachiel.config"
        "ngCordova"
        "restangular"
        "ionic"
        "ngAnimate"
        "underscore"
        "angular-progress-arc"
        # "pascalprecht.translate"
        "barachiel.i18n"
        "barachiel.utils.directives"
        "barachiel.utils.services"
        "barachiel.device.services"
        "barachiel.auth.services"
        "barachiel.auth.controllers"
        "barachiel.directives"
        "barachiel.filters"
        "barachiel.controllers"
        "barachiel.services"
    ])
    .run(($ionicPlatform, $rootScope, $state, $window, AuthService) ->
        $window['$rootScope'] = $rootScope

        $ionicPlatform.ready ->
            console.log "Barachiel running on #{window.platform_service_definition.name}"

            # Hide the accessory bar by default (remove this to show the accessory
            # bar above the keyboard for form inputs)
            if window.cordova and window.cordova.plugins.Keyboard
                cordova.plugins.Keyboard.hideKeyboardAccessoryBar false
            # org.apache.cordova.statusbar required
            StatusBar.styleDefault() if window.StatusBar

            if AuthService.state_requires_auth($state.current) and not AuthService.isAuthenticated(true)
                $state.transitionTo "st.signup"

            $rootScope.$on "$stateChangeStart", (event, toState, toParams, fromState, fromParams) ->
                if AuthService.state_requires_auth(toState) and not AuthService.isAuthenticated()
                    # User isn’t authenticated
                    $state.transitionTo "st.signup"
                    event.preventDefault()
                return
    )
    .config(($stateProvider, $urlRouterProvider, i18nProvider, $httpProvider, RestangularProvider, BASE_URL) ->

        ####### Interceptors ########
        $httpProvider.interceptors.push('authHttpResponseInterceptor');

        # RESTANGULAR
        RestangularProvider.setBaseUrl(BASE_URL)
        RestangularProvider.setRequestSuffix('/')

        ####### Internationalization ########
        i18nProvider.lang('en')
        # i18nProvider.translations('%radar.title': 'Radar')

        ####### Routing ########
        $stateProvider
            .state("st",
                abstract: true
                template: '<ui-view/>'
                # resolve: i18n: (i18n) -> i18n.loadTranslations "/localizations/#{i18n.lang}.json"
                resolve: i18n: (i18n) -> i18n.loadTranslations "https://dl.dropboxusercontent.com/u/4461171/web/en.json"
            )
            .state("st.login",
                url: "/login"
                templateUrl: "templates/login.html"
                controller: "LoginCtrl"
                authenticate: false
            )
            .state("st.forgot_password",
                url: "/forgot_password"
                templateUrl: "templates/forgot_password.html"
                controller: "ForgotPasswordCtrl"
                authenticate: false
            )
            .state("st.signup",
                url: "/signup"
                templateUrl: "templates/signup.html"
                controller: "SignupCtrl"
                authenticate: false
            )
            .state("st.tutorial",
                url: "/tutorial"
                templateUrl: "templates/tutorial.html"
                controller: "TutorialCtrl"
                authenticate: false
            )
            .state("st.tab",
                url: "/tab"
                abstract: true
                templateUrl: "templates/tabs.html"
                controller: 'TabCtrl'
            )
            .state("st.tab.radar",
                url: "/radar"
                #authenticate undefined is equivalent to authenticate = true.
                views:
                    "tab-radar":
                        templateUrl: "templates/tab-radar.html"
                        controller: "RadarCtrl"
            )
            .state("st.tab.radar-user-detail",
                url: "/radar/user/:userId"
                views:
                    "tab-radar":
                        templateUrl: "templates/user-detail.html"
                        controller: "UserDetailCtrl"
            )
            .state("st.tab.wavers",
                url: "/wavers"
                views:
                    "tab-wavers":
                        templateUrl: "templates/tab-wavers.html"
                        controller: "WaversCtrl"
            )
            .state("st.tab.waver-detail",
                url: "/waver/:waverId"
                views:
                    "tab-wavers":
                        templateUrl: "templates/waver-detail.html"
                        controller: "WaverDetailCtrl"
            )
            .state("st.tab.waver-user-detail",
                url: "/waver/user/:userId"
                views:
                    "tab-wavers":
                        templateUrl: "templates/user-detail.html"
                        controller: "UserDetailCtrl"
            )
            .state("st.tab.profile",
                url: "/profile"
                views:
                    "tab-profile":
                        templateUrl: "templates/tab-profile.html"
                        controller: "ProfileCtrl"
            )

        # if none of the above states are matched, use this as the fallback
        $urlRouterProvider.otherwise "/tab/radar"
    )
