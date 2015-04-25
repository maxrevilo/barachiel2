angular.module("barachiel.device.services", [])

.factory "StorageService", ($window, $q, $cordovaPreferences, $ionicPlatform, ENVIRONMENT) ->
    if (ENVIRONMENT == 'production')
        get: (key) ->
            storedValue = null
            $ionicPlatform.ready ->
                 return $cordovaPreferences.get(key).then (value) ->
                      return value

        set: (key, value) ->
            $ionicPlatform.ready ->
                 $cordovaPreferences.set(key, value)
        delete: (key) -> delete
             $cordovaPreferences.set(key, value)
    else
        all: -> $window.localStorage
        #get: (key) -> $q.when $window.localStorage[key]
        get: (key) -> $window.localStorage[key]
        set: (key, value) -> $window.localStorage[key] = value
        delete: (key) -> delete $window.localStorage[key]
        delete_all: () -> delete $window.localStorage.clear()
