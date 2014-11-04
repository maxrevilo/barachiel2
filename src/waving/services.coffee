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

.factory "User", (BASE_URL, $q, MediaManipulation, $window) ->
    change_image: (image_uri) ->
        MediaManipulation.upload_file BASE_URL + '/multimedia/user/', image_uri


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

.factory "MediaManipulation", (_, $q, $window, $ionicPlatform, $cordovaCamera, $cordovaFile) ->
    Camera = $window.Camera
    imageResizer = $window.imageResizer
    ImageResizer = $window.ImageResizer

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
        $cordovaFile.uploadFile url, file_uri, options

    # Warn: imageResizer crashes in android when getting images from PHOTOLIBRARY.
    # TODO: Crop functionality is needed
    resize_image: (image_uri, width, height) ->
        deferred = $q.defer()
        $ionicPlatform.ready ->
            imageResizer.getImageSize ((size)->
                console.log("Original image size: " + size.width + "x" + size.height)

                if size.width > width || size.height > height
                    imageResizer.resizeImage (
                        (result) -> deferred.resolve result.imageData
                    ), ((error) -> deferred.reject "Not able to resize image: " + error
                    ), image_uri, 800, 800,
                        'imageDataType': ImageResizer.IMAGE_DATA_TYPE_URL
                        'resizeType': ImageResizer.RESIZE_TYPE_MAX_PIXEL
                        'format': ImageResizer.FORMAT_JPG
                        'quality': 100
                        'pixelDensity': false
                        'storeImage': false

                else
                    deferred.resolve image_uri

            ), ((error)->
                deferred.reject "Not able to get the image size: " + error
            ),
                image_uri,

        deferred.promise
