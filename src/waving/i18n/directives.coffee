angular.module("barachiel.i18n.directives", [])
.directive 'translate', (l) ->
    scope: user:'='
    restrict: 'A'
    link: (scope, iElement, iAttrs) -> iElement.text l(iElement.text().trim())