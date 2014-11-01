angular.module("barachiel.controllers", [])

.controller("TabCtrl", ($scope, $state, $ionicModal) ->
    $scope.modal = null
    $scope.open_settings = ()->
        $scope.modal.show() if $scope.modal
        false

    modal_scope = $scope.$new()
    modal_scope.priv_rules = ["name", "picture", "age", "ss", "tel", "email", "bio"]
    modal_scope.goTutorial = ->
        modal_scope.modal.hide()
        $state.go "tutorial"

    $ionicModal.fromTemplateUrl('templates/settings.html'
        scope: modal_scope,
        animation: 'slide-in-up'
    )
    .then (modal) ->
        $scope.modal = modal
        modal_scope.modal = modal

    # $scope.$on '$destroy', () -> $scope.modal.remove()
    # $scope.$on 'modal.hidden', () ->
)

.controller("TutorialCtrl", ($scope, $state, $ionicSlideBoxDelegate) ->
    $scope.first = -> $ionicSlideBoxDelegate.slide(0)
    $scope.next = -> $ionicSlideBoxDelegate.next()
    $scope.exit = -> $state.go "tab.radar"
)

.controller("RadarCtrl", ($scope, $ionicPlatform, Users, $http, BASE_URL, $window) ->
    $scope.users = Users.all()

    $scope.doRefresh = ->
        $http.get BASE_URL + '/users/me/'
        setTimeout (->
            $scope.users.unshift name: "Other User"
            $scope.$broadcast "scroll.refreshComplete"
            $scope.$apply()
        ), 1000
)

.controller("WaversCtrl", ($scope, Wavers) ->
    $scope.wavers = Wavers.all()
)

.controller("WaverDetailCtrl", (_, $scope, $stateParams, Wavers) ->
    $scope.waver = Wavers.get($stateParams.waverId)
    $scope.waver.__safe__name = _.escape $scope.waver.name
    # "imgs/avatars/u_anonym.png"
)

.controller("ProfileCtrl", ($scope, $stateParams, $ionicActionSheet, l, User, MediaManipulation) ->
    $scope.profile =
        'name': 'Oliver Alejandro Perez Camargo'
        'password': 'Password'
        'wave_count': 12
        'phone': '+57(301) 477-79-12'
        'email': 'oliver.a.perez.c@gmail.com'
        'sex': 'Hombre'
        'age': 32
        'interested': 'Interested'
        'sentimental_status': 'Single'
        'bio': null

    $scope.takePicture = ()->
        $ionicActionSheet.show
            buttons: [
                {text: l("Photoalbun")}
                {text: l("Camera")}
            ]
            titleText: l("How to get the image")
            cancelText: l("Cancel")
            cancel: -> true
            buttonClicked: (index) ->
                MediaManipulation.get_pitcute(index==1)
                    .then ((imageURI) ->
                        User.change_image imageURI
                            .then ((result) ->
                            ) , ((err) ->
                            ) , ((progress) ->
                            )
                    ), ((err) ->
                        return
                    )
                true

)

.controller("UserDetailCtrl", ($scope, $stateParams, Users) ->
    user = Users.get($stateParams.userId)
    $scope.user =
        'name': user.name
        'password': 'Password'
        'wave_count': 12
        'phone': '+57(301) 477-79-12'
        'email': 'oliver.a.perez.c@gmail.com'
        'sex_str': 'Hombre'
        'age': 32
        'interested_str': 'Interested'
        'sentimental_status_str': 'Single'
        'bio': null
)