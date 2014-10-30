angular.module("barachiel.directives", [])
.directive 'ygUserItem', () ->
    UserItem =
        scope: user:'='
        controller: ($scope, $element, $attrs, $transclude) ->
            $element.on 'click', -> window.location.hash = $attrs.href
        restrict: 'AEC'
        templateUrl: 'templates/user-item.html'
        # priority: 1
        # terminal: true|false
        # require: 'controllerName|?controllerName|^controllerName'
        # replace: true|false
        # transclude: true|false|'element'
        # compile: (tElement, tAttrs, transclude) ->
        #     compiler =
        #         pre: (scope, iElement, iAttrs, controller) ->
        #             #not safe for DOM transformation
        #             #
        #         post: (scope, iElement, iAttrs, controller) ->
        #             #safe for DOM transformation
        #             #
        #     return compiler
        
        # #called IFF compile not defined
        # link: (scope, iElement, iAttrs) ->
        #     #register DOM listeners or update DOM
        #     #
        
    return UserItem