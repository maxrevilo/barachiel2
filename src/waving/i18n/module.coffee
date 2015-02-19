angular.module("barachiel.i18n", [
    'barachiel.i18n.directives'
    'barachiel.i18n.services'
    'barachiel.i18n.filters'
])
.provider "i18n", ()->
    lang = 'en'
    translations = 'hola': 'hello'

    @lang = (val) -> lang = val if val?
    @translations = (val) -> lang = val if val?

    @$get = ['$http', '$q', ($http, $q) ->
        lang: lang,
        translations: translations,
        loadTranslations: (url) ->
            deferred = $q.defer()
            $http.get(url).success (result) =>
                @translations = JSON.parse JSON.stringify result
                deferred.resolve this
            return deferred.promise

        translate: (key, args) ->
            if not (typeof args is "object" and args instanceof Array)
                if typeof args is "string"
                    args = [args]
                else args = []

            value = @translations[key]
            value = key if not value?

            for arg, a in args
                value = value.replace "{#{a}}", arg

            return value
    ]
    return
