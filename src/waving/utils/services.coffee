angular.module("barachiel.utils.services", [])

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

.factory "utils", (_, l, Messenger) ->
    to_form_params: (obj) -> _(_(_(obj).pairs()).map((e) -> _(e).join '=' )).join '&'
    from_form_params: (raw_data) ->
        _(raw_data.split('&'))
            .reduce ((obj, str)->
                sp=str.split("=")
                obj[sp[0]]=sp[1]
                obj
            ), {}
    translateAndSay: (tkey, args) -> Messenger.say l(tkey, args)
    parseFormErrors: (errors) -> (_(errors).reduce ((arr, error) -> arr.concat error[0]), []).join(', ')

# .factory "l", ($window) -> (text, args) -> $window.l text, args

.factory "MediaManipulation", (_, $q, $window, $ionicPlatform, $cordovaCamera, $cordovaFile) ->
    get_pitcute: (user_camera)->
        deferred = $q.defer()
        $ionicPlatform.ready ->
            Camera = $window.Camera
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

            $cordovaCamera.getPicture(options).then(
                ((arg)-> deferred.resolve arg),
                ((arg)-> deferred.reject arg),
                ((arg)-> deferred.notify arg),
            )

        deferred.promise

    upload_file: (url, file_uri) ->
        options =
            'chunkedMode': true
        $cordovaFile.uploadFile url, file_uri, options

    # Warn: imageResizer crashes in android when getting images from PHOTOLIBRARY.
    # TODO: Crop functionality is needed
    resize_image: (image_uri, width, height) ->
        deferred = $q.defer()
        $ionicPlatform.ready ->
            imageResizer = $window.imageResizer
            ImageResizer = $window.ImageResizer

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
