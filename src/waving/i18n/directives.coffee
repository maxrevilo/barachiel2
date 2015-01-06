angular.module("barachiel.i18n.directives", [])
.directive 'translate', (l) ->
    scope: user:'='
    restrict: 'A'
    priority: 1
    link: (scope, iElement, iAttrs) ->
        scope.$watch(iAttrs.ngBind, (new_binded_value) ->
          iElement.text l(iElement.text().trim())
        )
