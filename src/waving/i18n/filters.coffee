angular.module("barachiel.i18n.filters", [])
.filter "translate", (l)->
    (text, args) -> l text, args
