angular.module("barachiel.auth.services", [])
.factory "AuthService", ($http, _, utils, $log, StorageService, BASE_URL) ->
    _is_auth = Boolean StorageService.get 'user'
    #_is_auth = true

    set_user = (user) -> StorageService.set 'user', JSON.stringify user

    Authenticate: (credentials) ->
        $http(
            method: 'POST'
            url: BASE_URL + '/auth/login/'
            data: utils.to_form_params credentials
            headers: 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        )
            .success (user, status, headers, config) ->
                set_user(user)
                _is_auth = true
                return user
            .error (data) -> $log.error "Couldn't Authenticate: " + data

    Logout: () ->
        StorageService.delete_all()
        $http.get BASE_URL + '/auth/logout/', {}
            .success () ->
                _is_auth = false
            .error (data) -> $log.error "Couldn't Logout: " + data

    Signup: (credentials) ->
        $http(
            method: 'POST'
            url: BASE_URL + '/auth/signup/'
            data: utils.to_form_params credentials
            headers: 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        )
            .success (user, status, headers, config) ->
                set_user(user)
                _is_auth = true
                return user
            .error (data) -> $log.error "Couldn't Signup: " + data

    isAuthenticated: (http_check=false) ->
        if _is_auth and http_check
            $http.get BASE_URL + '/users/me'
                .success (user) -> set_user(user)
        _is_auth

    state_requires_auth: ($state) -> not angular.isDefined($state.authenticate) or $state.authenticate

.factory "authHttpResponseInterceptor", ($q, $injector) ->
    response: (response) -> response or $q.when(response)

    responseError: (rejection) ->
        if rejection.status is 401
            console.warn "Response Error 401", rejection
            $injector.get('AuthService').Logout()
            $injector.get('$state').transitionTo "signup"
        $q.reject rejection