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


angular.module("barachiel.util.services", [])

.factory "Messenger", ($window) ->
    say: (message) ->
        $window.alert message

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
