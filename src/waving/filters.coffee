angular.module("barachiel.filters", [])
.filter "byDistance", (_)->
    (users, min, max) ->
        _(users).filter (user) -> (user.d or 0) >= min and (user.d or 0) < max
