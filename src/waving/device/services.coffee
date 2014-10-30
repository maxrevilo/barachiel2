angular.module("barachiel.device.services", [])

.factory "StorageService", ($window) ->
    all: -> $window.localStorage
    get: (key) -> $window.localStorage[key]
    set: (key, value) -> $window.localStorage[key] = value
    delete: (key) -> delete $window.localStorage[key]
    delete_all: () -> delete $window.localStorage.clear()
