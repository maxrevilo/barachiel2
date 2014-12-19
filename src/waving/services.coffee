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

    #Enums
    Users.SentimentalStatus = 
        DontSay           : 'U', Single            : 'S',
        Married           : 'M', InRelationShip    : 'R'

    Users.Sex = DontSay : 'U', Male    : 'M', Female  : 'F'

    Users.RelInterest =
        DontSay      : 'U', Male    : 'M', Female  : 'F',
        Both         : 'B', Firends : 'R'

    Users.ToTextMappings = SentimentalStatus: {}, Sex: {}, RelInterest: {}

    Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.DontSay]        = l("%global.unrevealed")
    Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.Single]         = l("%global.sstatus.single")
    Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.Married]        = l("%global.sstatus.married")
    Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.InRelationShip] = l("%global.sstatus.in_a_relationship")

    Users.ToTextMappings.Sex[Users.Sex.DontSay] = l("%global.unrevealed")
    Users.ToTextMappings.Sex[Users.Sex.Male]    = l("%global.gender.M")
    Users.ToTextMappings.Sex[Users.Sex.Female]  = l("%global.gender.F")

    Users.ToTextMappings.RelInterest[Users.RelInterest.DontSay] = l("%global.unrevealed")
    Users.ToTextMappings.RelInterest[Users.RelInterest.Male]    = l("%global.rel_interest.male")
    Users.ToTextMappings.RelInterest[Users.RelInterest.Female]  = l("%global.rel_interest.female")
    Users.ToTextMappings.RelInterest[Users.RelInterest.Both]    = l("%global.rel_interest.both")
    Users.ToTextMappings.RelInterest[Users.RelInterest.Friends] = l("%global.rel_interest.friends")
    
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

        user.sentimentalStatusHR = () -> Users.ToTextMappings.SentimentalStatus[@sentimental_status]
        user.sexHR = () -> Users.ToTextMappings.SentimentalStatus[@sex]
        user.relInterestHR = () -> Users.ToTextMappings.SentimentalStatus[@r_interest]

        if user.picture?
            user.s_picture = user.picture
        else
            default_img = 'img/avatars/' + (user.sex or 'u').toLowerCase() + '_anonym.png'
            user.s_picture = 'id': -1, 'type': "I", 'uploader_id': -1
                , 'xBig': default_img, 'xFull': default_img, 'xLit': default_img

        user

    Users
