angular.module("barachiel.services", [])

.factory "Wavers", ->
    wavers =  [
        { id: 0, name: 'Scruff McGruff', user_id: 0 },
        { id: 1, name: 'G.I. Joe', user_id: 1 },
        { id: 2, name: 'Miss Frizzle', user_id: 2 },
    ]

    all: -> wavers
    get: (waverId) -> wavers[waverId]

.factory "Users", (BASE_URL, _, $q, l, Restangular, AuthService, MediaManipulation, $timeout) ->
    #Le Service
    Users = Restangular.service 'users'

    # Model Manager Methods
    Users.all = -> @getList()
    Users.get = (id)-> @one(id).get()
    Users.me = (force_request)->
        promise = null
        if not @_me?
            userData = AuthService.GetUser()
            if userData?
                @set_me(userData)
            else
                throw new Error("Local user not found")
        if force_request
            # Forcing a request to the server
            @_me.get()
        return @_me

    Users.set_me = (rawUserJSON) -> @_me = Restangular.restangularizeElement '', rawUserJSON, 'users', {}
    
    # Model Methods
    Restangular.extendModel "users", (user) ->
        user.change_image = (image_uri) ->
            MediaManipulation.upload_file BASE_URL + '/multimedia/user/', image_uri
            .then(
                ((result)=>
                    @picture = JSON.parse result.response
                ),
                ((error)=> error),
            )

        if user.picture?
            user.s_picture = user.picture
        else
            default_img = 'imgs/avatars/' + (user.sex or 'u').toLowerCase() + '_anonym.png'
            user.s_picture = 'id': -1, 'type': "I", 'uploader_id': -1
                , 'xBig': default_img, 'xFull': default_img, 'xLit': default_img

        user

    Users
