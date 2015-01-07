angular.module("barachiel.services", [])

.factory "Likes", (Restangular, Users)->
    Likes = Restangular.service 'likes'

    Likes.toMe = ()-> @getList()
    Likes.get = (id)-> @one(id).get()

    Restangular.extendModel "likes", (waver) ->
        waver.s_picture = Users.getPicture waver.user
        waver.user = Restangular.restangularizeElement '', waver.user, 'users', {}
        return waver

    return Likes

.factory "Users", (BASE_URL, _, l, $injector, Restangular, AuthService, MediaManipulation, $q) ->
    Likes = null #This will be the Likes restangular service.

    #Le Service
    Users = Restangular.service 'users'

    me_deferred = $q.defer();

    # Model Manager Methods
    Users.all = -> @getList()
    Users.get = (id)-> @one(id).get()
    Users.me = (force_request)->
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

    Users.me_promise = () -> me_deferred.promise

    Users.set_me = (rawUserJSON) ->
        @_me = Restangular.restangularizeElement '', rawUserJSON, 'users', {}
        me_deferred.resolve @_me
        return @_me

    Users.getPicture = (user) ->
        if user and user.picture?
            return user.picture
        else
            sex = (if user and user.sex then user.sex else 'u').toLowerCase()
            default_img = 'img/avatars/' + sex + '_anonym.png'
            
            return  'id': -1, 'type': "I", 'uploader_id': -1
                    , 'xBig': default_img, 'xFull': default_img,
                    'xLit': default_img

    #Enums
    Users.SentimentalStatus =
        DontSay           : 'U', Single            : 'S',
        Married           : 'M', InRelationShip    : 'R'

    Users.Sex = DontSay : 'U', Male    : 'M', Female  : 'F'

    Users.RelInterest =
        DontSay      : 'U', Male    : 'M', Female  : 'F',
        Both         : 'B', Firends : 'R'

    Users.ToTextMappings = SentimentalStatus: {}, Sex: {}, RelInterest: {}

    Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.DontSay]        = "%global.unrevealed"
    Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.Single]         = "%global.sstatus.single"
    Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.Married]        = "%global.sstatus.married"
    Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.InRelationShip] = "%global.sstatus.in_a_relationship"

    Users.ToTextMappings.Sex[Users.Sex.DontSay] = "%global.unrevealed"
    Users.ToTextMappings.Sex[Users.Sex.Male]    = "%global.gender.M"
    Users.ToTextMappings.Sex[Users.Sex.Female]  = "%global.gender.F"

    Users.ToTextMappings.RelInterest[Users.RelInterest.DontSay] = "%global.unrevealed"
    Users.ToTextMappings.RelInterest[Users.RelInterest.Male]    = "%global.rel_interest.male"
    Users.ToTextMappings.RelInterest[Users.RelInterest.Female]  = "%global.rel_interest.female"
    Users.ToTextMappings.RelInterest[Users.RelInterest.Both]    = "%global.rel_interest.both"
    Users.ToTextMappings.RelInterest[Users.RelInterest.Friends] = "%global.rel_interest.friends"
    
    # Model Methods
    Restangular.extendModel "users", (user) ->
        Likes = $injector.get "Likes"

        user.change_image = (image_uri) ->
            return MediaManipulation.upload_file BASE_URL + '/multimedia/user/', image_uri
                .then(
                    ((result)=>
                        @picture = JSON.parse result.response
                    ),
                    ((error)=> error),
                )

        user.sentimentalStatusHR = () -> Users.ToTextMappings.SentimentalStatus[@sentimental_status]
        user.sexHR = () -> Users.ToTextMappings.SentimentalStatus[@sex]
        user.relInterestHR = () -> Users.ToTextMappings.SentimentalStatus[@r_interest]

        # Hydratation:
        user.refreshLikesTo = () ->
            promise = Likes.toMe()
            return promise.then (likes) ->
                user.likes_to.length = 0 # Empty the array
                Array.prototype.push.apply(user.likes_to, likes)
                return likes

        user.likes_to =  Restangular.restangularizeCollection '', user.liked, 'likes', {} if user.liked?
        user.likes_from =  Restangular.restangularizeCollection '', user.likes, 'likes', {} if user.likes?

        user.s_picture = Users.getPicture user

        return user

    return Users
