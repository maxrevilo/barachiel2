angular.module("barachiel.auth.controllers", [])

.controller("SignupCtrl", (_, $scope, $state, AuthService, Loader, utils) ->
    $scope.forms = {}

    $scope.signup = (user)->
        if $scope.forms.signupForm.$invalid
            $scope.showErrors = yes
        else
            Loader.show $scope
            AuthService.Signup(user).then(
                -> #Success
                    Loader.hide $scope
                    $state.go "tutorial"
                (jqXHR) -> #Error
                    Loader.hide $scope
                    switch jqXHR.status
                        when 0 then utils.translateAndSay("%global.error.server_not_found")
                        when 403 then utils.translateAndSay("%global.error.invalid_register_form_{{val}}",
                            'val': jqXHR.responseText)
                        else utils.translateAndSay("%global.error.std_{{val}}", 'val': utils.parseFormErrors jqXHR.data)
            )
)

.controller("LoginCtrl", (_, $scope, $state, AuthService, Loader, utils) ->
    $scope.forms = {}

    $scope.login = (user)->
        if $scope.forms.loginForm.$invalid
            $scope.showErrors = yes
        else
            Loader.show $scope
            creds =
                'username': user.email
                'password': user.password
            AuthService.Authenticate(creds).then(
                -> #Success
                    Loader.hide $scope
                    $state.go "tab.radar"
                (jqXHR) -> #Error
                    Loader.hide $scope
                    switch jqXHR.status
                        when 0 then utils.translateAndSay("%global.error.server_not_found")
                        when 403 then utils.translateAndSay("%global.error.invalid_email_or_passwd")
                        else utils.translateAndSay("%global.error.std_{{val}}", 'val': utils.parseFormErrors jqXHR.data)
            )
)

.controller("ForgotPasswordCtrl", ($scope, $state, Messenger) ->
    $scope.reset_password = (email) -> setTimeout (-> Messenger.say "New password sent to #{email}"), 100
)