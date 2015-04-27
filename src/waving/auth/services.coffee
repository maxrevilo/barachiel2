angular.module("barachiel.auth.services", [])
.factory "AuthService", ($rootScope, $http, $log, _, utils, StorageService, analytics, API_URL) ->
    _is_auth = ->
        if $rootScope.user?
            yes
        else
            no

    _set_user = (user) ->
        StorageService.set 'user', JSON.stringify user
        analytics.setUser user
        return $rootScope.user = user

    _unset_user = ->
        $rootScope.user = null
        StorageService.delete 'user'

    #Service
    Authenticate: (credentials) ->
        $http(
            method: 'POST'
            url: API_URL + '/auth/login/'
            data: utils.to_form_params credentials
            headers: 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        )
            .success (user, status, headers, config) -> _set_user user
            .error (data) -> $log.error "Couldn't Authenticate: " + data

    Logout: ->
        $http.get API_URL + '/auth/logout/', {}
            .success -> _unset_user()
            .error (data) -> $log.error "Couldn't Logout: " + data

    Signup: (credentials) ->
        $http(
            method: 'POST'
            url: API_URL + '/auth/signup/'
            data: utils.to_form_params credentials
            headers: 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        )
            .success (user, status, headers, config) -> _set_user user
            .error (data) -> $log.error "Couldn't Signup: " + data

    GetUser: -> $rootScope.user if _is_auth()

    isAuthenticated: (http_check=false) ->
        if _is_auth() and http_check
            $http.get API_URL + '/users/me/'
                .success (user) -> _set_user user
        _is_auth()

    resetPasswordOf: (user_email) ->
        $http(
            method: 'POST'
            url: API_URL + '/auth/reset_password/'
            data: utils.to_form_params {"email": user_email}
            headers: 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        )

    state_requires_auth: ($state) -> not angular.isDefined($state.authenticate) or $state.authenticate

.factory "authHttpResponseInterceptor", ($q, $injector) ->
    response: (response) -> response or $q.when(response)

    responseError: (rejection) ->
        if rejection.status is 401
            console.warn "Response Error 401", rejection
            $injector.get('AuthService').Logout()
            $injector.get('$state').transitionTo "st.signup"
        $q.reject rejection
