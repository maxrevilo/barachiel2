angular.module("barachiel.device.services", [])

.factory "StorageService", ($window, $q, $cordovaPreferences, $ionicPlatform, ENVIRONMENT) ->
    if (ENVIRONMENT == 'production' || ENVIRONMENT == 'phonedev')
        get: (key) ->
            $ionicPlatform.ready ->
                 return $cordovaPreferences.get(key).then (value) ->
                      return value
        set: (key, value) ->
            $ionicPlatform.ready ->
                 $cordovaPreferences.set(key, value)
        delete: (key) -> delete
            $ionicPlatform.ready ->
                $cordovaPreferences.set(key, null)
    else
        all: -> $window.localStorage
        get: (key) ->
            $q.when $window.localStorage[key]
        set: (key, value) -> $q.when($window.localStorage[key] = value)
        delete: (key) -> $q.when delete $window.localStorage[key]
        delete_all: () -> delete $window.localStorage.clear()

#.factory "WaversPrefService", StorageService ->
    #get_wavers: -> StorageService.set 'wavers'
    #get_wave_attr: (id, attr) ->
    #set_wavers: (value)->
    #set_wave_attr: (id, attr, value) ->
