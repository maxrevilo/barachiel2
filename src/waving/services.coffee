angular.module("barachiel.services", []).

factory "Wavers", ->
    wavers =  [
        { id: 0, name: 'Scruff McGruff', user_id: 0 },
        { id: 1, name: 'G.I. Joe', user_id: 1 },
        { id: 2, name: 'Miss Frizzle', user_id: 2 },
    ]

    all: -> wavers
    get: (waverId) -> wavers[waverId]

.factory "Users", ->
    users = [
        { id: 0, name: 'Scruff McGruff' },
        { id: 1, name: 'G.I. Joe' },
        { id: 2, name: 'Miss Frizzle' },
        { id: 3, name: 'Ash Ketchum' }
    ]

    all: -> users
    get: (userId) -> users[userId]

.factory "User", (BASE_URL, MediaManipulation) ->
    change_image: (image_uri) ->
        MediaManipulation.upload_file BASE_URL + '/multimedia/user/', image_uri
            .then ((result) ->
              # TODO: Set the user image
            ) , ((err) ->
              # TODO: Reset the user image
            )


angular.module("barachiel.util.services", [])

.factory "Messenger", ($window, $ionicPopup, l) ->
    say: (message) ->
        $ionicPopup.alert(
            title: l("alert")
            template: message
        )

.factory "Loader", ($ionicLoading) ->
    show: (context) ->
        $ionicLoading.show template: 'Loading...'
    hide: (context) ->
        $ionicLoading.hide()

.factory "utils", (_, $translate, Messenger) ->
    to_form_params: (obj) -> _(_(_(obj).pairs()).map((e) -> _(e).join '=' )).join '&'
    from_form_params: (raw_data) ->
        _(raw_data.split('&'))
            .reduce ((obj, str)->
                sp=str.split("=")
                obj[sp[0]]=sp[1]
                obj
            ), {}
    translateAndSay: (tkey, args) -> $translate(tkey, args).then (msg)-> Messenger.say msg
    parseFormErrors: (errors) -> (_(errors).reduce ((arr, error) -> arr.concat error[0]), []).join(', ')

.factory "l", (_) -> (text, args) -> text

.factory "MediaManipulation", (_, $window, $cordovaCamera, $cordovaFile) ->
    Camera = $window.Camera
    get_pitcute: (user_camera)->
        sourceType =
            if user_camera
            then Camera.PictureSourceType.CAMERA
            else Camera.PictureSourceType.PHOTOLIBRARY

        options =
            'quality': 75
            'destinationType': Camera.DestinationType.FILE_URI
            'sourceType': sourceType
            'allowEdit': true
            'encodingType': Camera.EncodingType.JPEG
            'targetWidth': 800
            'targetHeight': 800
            'saveToPhotoAlbum': false

        $cordovaCamera.getPicture(options)

    upload_file: (url, file_uri) ->
        options =
            'chunkedMode': true
        $cordovaFile.uploadFile window.encodeURI(url), file_uri, options
