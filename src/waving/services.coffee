angular.module("barachiel.services", [])

.factory "Likes", (Restangular, Users, utils)->
    Likes = Restangular.service 'likes'

    Likes.toMe = ()-> @getList()
    Likes.get = (id)-> @one(id).get()

    Likes.send = (user_id, is_anonymous)->
        postPromise = Restangular.all('likes/from').customPOST(
            utils.to_form_params('user_id': user_id, 'anonym': is_anonymous),
            '', {},
            "Content-Type":'application/x-www-form-urlencoded'
        )
        postPromise = postPromise.then(
            (like) ->
                Users.me().likes.unshift like
                return like
        )
        return postPromise

    Likes.unlike = (user_id)->
        me = Users.me()
        like = me.getLikeByUserId user_id
        removePromise = like.remove().then((deletedLike) ->
            index = me.likes_from.indexOf(like)
            me.likes_from.splice(index, 1) if index != -1
            return deletedLike
        )

        return removePromise

    Restangular.extendModel "likes", (waver) ->
        waver.s_picture = Users.getPicture waver.user
        waver.user = Restangular.restangularizeElement '', waver.user, 'users', {}
        return waver

    return Likes

.factory "Users", ($rootScope, API_URL, _, l, $injector, Restangular, AuthService, MediaManipulation, $q) ->
    Likes = null #This will be the Likes restangular service.

    #Le Service
    Users = Restangular.service 'users'

    $rootScope.$watch "user", (user) -> Users.set_me user if user?

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

    Users.me_promise = () -> $q.when(@_me)

    Users.set_me = (rawUserJSON) ->
        @_me = Restangular.restangularizeElement '', rawUserJSON, 'users', {}
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
            return MediaManipulation.upload_file API_URL + '/multimedia/user/', image_uri
                .then(
                    ((result)=>
                        @picture = JSON.parse result.response
                        @s_picture = Users.getPicture @
                    ),
                    ((error)=> error),
                )

        user.sentimentalStatusHR = () -> Users.ToTextMappings.SentimentalStatus[@sentimental_status]
        user.sexHR = () -> Users.ToTextMappings.Sex[@sex]
        user.relInterestHR = () -> Users.ToTextMappings.RelInterest[@r_interest]

        user.refreshLikesTo = () ->
            promise = Likes.toMe()
            return promise.then (likes) ->
                user.likes_to.length = 0 # Empty the array
                Array.prototype.push.apply(user.likes_to, likes)
                return likes

        user.isLikedByMe = -> Users.me().getLikeByUserId(user.id)?

        user.getLikeByUserId = (user_id) -> _(@likes_from).find (like)-> like.user.id == user_id

        # Hydratation:
        user.likes_to =  Restangular.restangularizeCollection '', user.liked, 'likes', {} if user.liked?
        user.likes_from =  Restangular.restangularizeCollection '', user.likes, 'likes/from', {} if user.likes?

        user.s_picture = Users.getPicture user

        return user

    return Users
