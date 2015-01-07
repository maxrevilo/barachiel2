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
        $state.go "st.tutorial"

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
    $scope.exit = -> $state.go "st.tab.radar"
)

.controller("RadarCtrl", ($scope, l, Users, analytics) ->
    $scope.state = 'loading'
    $scope.error = {}
    last_mixpanel_detection = 0;

    $scope.refreshUsers = ->
        promise = null
        if $scope.users? and $scope.users.length > 0
            promise = $scope.users.getList()
        else
            promise = Users.all()
            $scope.users = promise.$object

        return promise.then(
            (users)->
                detections = users.length;
                if last_mixpanel_detection != detections
                    last_mixpanel_detection = detections;
                    analytics.track "radar.detections", "number": detections

                $scope.state = 'ready'
            (jqXHR)->
                $scope.state = 'error'
                $scope.error.message = switch jqXHR.status
                    when 0 then l("%global.error.server_not_found")
                    else jqXHR.statusText
        )

    $scope.doRefresh = ->
        $scope.refreshUsers().finally ->
            $scope.$broadcast "scroll.refreshComplete"

    # Call window.$rootScope.$broadcast("REFRESH_RADAR") to trigger.
    $scope.$on "REFRESH_RADAR", (ev, data)->
        $scope.refreshUsers()

    # Loading users
    $scope.refreshUsers()
)

.controller("WaversCtrl", ($scope, Users, Me) ->
    $scope.wavers = Me.likes_to
    Me.refreshLikesTo()
)

.controller("WaverDetailCtrl", (_, $scope, $stateParams, Likes) ->
    $scope.waver = { id: 0, name: 'Scruff McGruff', user_id: 0 }
    $scope.waver.__safe__name = _.escape $scope.waver.name
    # "imgs/avatars/u_anonym.png"
)

.controller("ProfileCtrl", ($rootScope, $scope, $stateParams, $state,
        $ionicActionSheet, l, AuthService, Users, MediaManipulation, $timeout) ->

    user = Users.me true
    $scope.profile = user

    if not $rootScope.uploadingPicture?
        $rootScope.uploadingPicture =
            'on': false, 'progress': 0, 'image': null,
            'start': (image)->
                @image = image
                @on = true
                @progress = 0
            'stop': ->
                @image = null
                @on = false
            'set': (progress)-> @progress = progress
            'increment': (inc)-> @progress += inc || 0.05
            'finish': ->
                @progress = 1
                $timeout (=> @stop()), 500
            'fail': -> this.stop()

    $scope.uploadingPicture = $rootScope.uploadingPicture

    $scope.logout = ->
        AuthService.Logout().then -> $state.go "st.signup"

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
                    .then (imageURI) ->
                        $scope.uploadingPicture.start imageURI
                        user.change_image imageURI
                    .then(
                        ((result) ->
                            $scope.uploadingPicture.finish()
                            console.log "Change Image Success"
                        ), null
                        , ((progressEvent) ->
                            if progressEvent.lengthComputable
                                $scope.uploadingPicture.set progressEvent.loaded / progressEvent.total
                            else
                                $scope.uploadingPicture.increment()
                        )
                    ).catch ((err) ->
                        $scope.uploadingPicture.fail()
                        throw new Error "Error changing image " + err
                    )
                true
)

.controller("UserDetailCtrl", ($scope, $stateParams, Users, analytics) ->
    userPromise = Users.get $stateParams.userId
    $scope.user = userPromise.$object

    $scope.sendLike = ->
        anonymous = false
        $scope.wave_loading = not $scope.wave_loading
        analytics.track "action.likes.send", 'type': if anonymous then 'anonymous' else 'direct'

        (jqXHR)->
            error_message = switch jqXHR.status
                when 0 then l("%global.error.server_not_found")
                else "#{jqXHR.statusText} - #{jqXHR.responseText}"

            analytics.track("action.likes.send.error",
                "type": "Server Request",
                "description": error_message,
                "status": jqXHR.status
            )

)