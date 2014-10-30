angular.module("barachiel", ["barachiel.config", "ionic", "underscore", "pascalprecht.translate", "barachiel.util.services", "barachiel.device.services", "barachiel.auth.services", "barachiel.auth.controllers", "barachiel.directives", "barachiel.controllers", "barachiel.services"]).run(function($ionicPlatform, $rootScope, $state, AuthService) {
  return $ionicPlatform.ready(function() {
    console.log("Barachiel running on " + window.platform_service_definition.name);
    if (window.cordova && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
    }
    if (window.StatusBar) {
      StatusBar.styleDefault();
    }
    if (AuthService.state_requires_auth($state.current) && !AuthService.isAuthenticated(true)) {
      $state.transitionTo("signup");
    }
    return $rootScope.$on("$stateChangeStart", function(event, toState, toParams, fromState, fromParams) {
      if (AuthService.state_requires_auth(toState) && !AuthService.isAuthenticated()) {
        $state.transitionTo("signup");
        event.preventDefault();
      }
    });
  });
}).config(function($stateProvider, $urlRouterProvider, $translateProvider, $httpProvider) {
  $httpProvider.interceptors.push('authHttpResponseInterceptor');
  $stateProvider.state("login", {
    url: "/login",
    templateUrl: "templates/login.html",
    controller: "LoginCtrl",
    authenticate: false
  }).state("signup", {
    url: "/signup",
    templateUrl: "templates/signup.html",
    controller: "SignupCtrl",
    authenticate: false
  }).state("forgot_password", {
    url: "/forgot_password",
    templateUrl: "templates/forgot_password.html",
    controller: "ForgotPasswordCtrl",
    authenticate: false
  }).state("tutorial", {
    url: "/tutorial",
    templateUrl: "templates/tutorial.html",
    controller: "TutorialCtrl",
    authenticate: false
  }).state("tab", {
    url: "/tab",
    abstract: true,
    templateUrl: "templates/tabs.html",
    controller: 'TabCtrl'
  }).state("tab.radar", {
    url: "/radar",
    views: {
      "tab-radar": {
        templateUrl: "templates/tab-radar.html",
        controller: "RadarCtrl"
      }
    }
  }).state("tab.radar-user-detail", {
    url: "/radar/user/:userId",
    views: {
      "tab-radar": {
        templateUrl: "templates/user-detail.html",
        controller: "UserDetailCtrl"
      }
    }
  }).state("tab.wavers", {
    url: "/wavers",
    views: {
      "tab-wavers": {
        templateUrl: "templates/tab-wavers.html",
        controller: "WaversCtrl"
      }
    }
  }).state("tab.waver-detail", {
    url: "/waver/:waverId",
    views: {
      "tab-wavers": {
        templateUrl: "templates/waver-detail.html",
        controller: "WaverDetailCtrl"
      }
    }
  }).state("tab.waver-user-detail", {
    url: "/waver/user/:userId",
    views: {
      "tab-wavers": {
        templateUrl: "templates/user-detail.html",
        controller: "UserDetailCtrl"
      }
    }
  }).state("tab.profile", {
    url: "/profile",
    views: {
      "tab-profile": {
        templateUrl: "templates/tab-profile.html",
        controller: "ProfileCtrl"
      }
    }
  });
  $urlRouterProvider.otherwise("/tab/radar");
  return $translateProvider.useStaticFilesLoader({
    prefix: '/localizations/',
    suffix: '.json'
  }).registerAvailableLanguageKeys(['en', 'es'], {
    'en_US': 'en',
    'en_UK': 'en',
    'es': 'es'
  }).fallbackLanguage('en').determinePreferredLanguage();
});

var config, config_module;

config = {
  APP_NAME: 'Waving',
  BASE_URL: 'http://barachiel.yougrups.webfactional.com'
};

config_module = angular.module("barachiel.config", []);

angular.forEach(config, function(key, value) {
  return config_module.constant(value, key);
});

angular.module("barachiel.controllers", []).controller("TabCtrl", function($scope, $state, $ionicModal) {
  var modal_scope;
  $scope.modal = null;
  $scope.open_settings = function() {
    if ($scope.modal) {
      $scope.modal.show();
    }
    return false;
  };
  modal_scope = $scope.$new();
  modal_scope.priv_rules = ["name", "picture", "age", "ss", "tel", "email", "bio"];
  modal_scope.goTutorial = function() {
    modal_scope.modal.hide();
    return $state.go("tutorial");
  };
  return $ionicModal.fromTemplateUrl('templates/settings.html', {
    scope: modal_scope,
    animation: 'slide-in-up'
  }).then(function(modal) {
    $scope.modal = modal;
    return modal_scope.modal = modal;
  });
}).controller("TutorialCtrl", function($scope, $state, $ionicSlideBoxDelegate) {
  $scope.first = function() {
    return $ionicSlideBoxDelegate.slide(0);
  };
  $scope.next = function() {
    return $ionicSlideBoxDelegate.next();
  };
  return $scope.exit = function() {
    return $state.go("tab.radar");
  };
}).controller("RadarCtrl", function($scope, Users, $http, BASE_URL) {
  $scope.users = Users.all();
  return $scope.doRefresh = function() {
    $http.get(BASE_URL + '/users/me');
    return setTimeout((function() {
      $scope.users.unshift({
        name: "Other User"
      });
      $scope.$broadcast("scroll.refreshComplete");
      return $scope.$apply();
    }), 1000);
  };
}).controller("WaversCtrl", function($scope, Wavers) {
  return $scope.wavers = Wavers.all();
}).controller("WaverDetailCtrl", function(_, $scope, $stateParams, Wavers) {
  $scope.waver = Wavers.get($stateParams.waverId);
  return $scope.waver.__safe__name = _.escape($scope.waver.name);
}).controller("ProfileCtrl", function($scope, $stateParams) {
  return $scope.profile = {
    'name': 'Oliver Alejandro Perez Camargo',
    'password': 'Password',
    'wave_count': 12,
    'phone': '+57(301) 477-79-12',
    'email': 'oliver.a.perez.c@gmail.com',
    'sex': 'Hombre',
    'age': 32,
    'interested': 'Interested',
    'sentimental_status': 'Single',
    'bio': null
  };
}).controller("UserDetailCtrl", function($scope, $stateParams, Users) {
  var user;
  user = Users.get($stateParams.userId);
  return $scope.user = {
    'name': user.name,
    'password': 'Password',
    'wave_count': 12,
    'phone': '+57(301) 477-79-12',
    'email': 'oliver.a.perez.c@gmail.com',
    'sex_str': 'Hombre',
    'age': 32,
    'interested_str': 'Interested',
    'sentimental_status_str': 'Single',
    'bio': null
  };
});

angular.module("barachiel.directives", []).directive('ygUserItem', function() {
  var UserItem;
  UserItem = {
    scope: {
      user: '='
    },
    controller: function($scope, $element, $attrs, $transclude) {
      return $element.on('click', function() {
        return window.location.hash = $attrs.href;
      });
    },
    restrict: 'AEC',
    templateUrl: 'templates/user-item.html'
  };
  return UserItem;
});

angular.module("barachiel.services", []).factory("Wavers", function() {
  var wavers;
  wavers = [
    {
      id: 0,
      name: 'Scruff McGruff',
      user_id: 0
    }, {
      id: 1,
      name: 'G.I. Joe',
      user_id: 1
    }, {
      id: 2,
      name: 'Miss Frizzle',
      user_id: 2
    }
  ];
  return {
    all: function() {
      return wavers;
    },
    get: function(waverId) {
      return wavers[waverId];
    }
  };
}).factory("Users", function() {
  var users;
  users = [
    {
      id: 0,
      name: 'Scruff McGruff'
    }, {
      id: 1,
      name: 'G.I. Joe'
    }, {
      id: 2,
      name: 'Miss Frizzle'
    }, {
      id: 3,
      name: 'Ash Ketchum'
    }
  ];
  return {
    all: function() {
      return users;
    },
    get: function(userId) {
      return users[userId];
    }
  };
});

angular.module("barachiel.util.services", []).factory("Messenger", function($window) {
  return {
    say: function(message) {
      return $window.alert(message);
    }
  };
}).factory("Loader", function($ionicLoading) {
  return {
    show: function(context) {
      return $ionicLoading.show({
        template: 'Loading...'
      });
    },
    hide: function(context) {
      return $ionicLoading.hide();
    }
  };
}).factory("utils", function(_, $translate, Messenger) {
  return {
    to_form_params: function(obj) {
      return _(_(_(obj).pairs()).map(function(e) {
        return _(e).join('=');
      })).join('&');
    },
    from_form_params: function(raw_data) {
      return _(raw_data.split('&')).reduce((function(obj, str) {
        var sp;
        sp = str.split("=");
        obj[sp[0]] = sp[1];
        return obj;
      }), {});
    },
    translateAndSay: function(tkey, args) {
      return $translate(tkey, args).then(function(msg) {
        return Messenger.say(msg);
      });
    },
    parseFormErrors: function(errors) {
      return (_(errors).reduce((function(arr, error) {
        return arr.concat(error[0]);
      }), [])).join(', ');
    }
  };
});

angular.module("barachiel.auth.controllers", []).controller("SignupCtrl", function(_, $scope, $state, AuthService, Loader, utils) {
  $scope.forms = {};
  return $scope.signup = function(user) {
    if ($scope.forms.signupForm.$invalid) {
      return $scope.showErrors = true;
    } else {
      Loader.show($scope);
      return AuthService.Signup(user).then(function() {
        Loader.hide($scope);
        return $state.go("tutorial");
      }, function(jqXHR) {
        Loader.hide($scope);
        switch (jqXHR.status) {
          case 0:
            return utils.translateAndSay("%global.error.server_not_found");
          case 403:
            return utils.translateAndSay("%global.error.invalid_register_form_{{val}}", {
              'val': jqXHR.responseText
            });
          default:
            return utils.translateAndSay("%global.error.std_{{val}}", {
              'val': utils.parseFormErrors(jqXHR.data)
            });
        }
      });
    }
  };
}).controller("LoginCtrl", function(_, $scope, $state, AuthService, Loader, utils) {
  $scope.forms = {};
  return $scope.login = function(user) {
    var creds;
    if ($scope.forms.loginForm.$invalid) {
      return $scope.showErrors = true;
    } else {
      Loader.show($scope);
      creds = {
        'username': user.email,
        'password': user.password
      };
      return AuthService.Authenticate(creds).then(function() {
        Loader.hide($scope);
        return $state.go("tab.radar");
      }, function(jqXHR) {
        Loader.hide($scope);
        switch (jqXHR.status) {
          case 0:
            return utils.translateAndSay("%global.error.server_not_found");
          case 403:
            return utils.translateAndSay("%global.error.invalid_email_or_passwd");
          default:
            return utils.translateAndSay("%global.error.std_{{val}}", {
              'val': utils.parseFormErrors(jqXHR.data)
            });
        }
      });
    }
  };
}).controller("ForgotPasswordCtrl", function($scope, $state, Messenger) {
  return $scope.reset_password = function(email) {
    return setTimeout((function() {
      return Messenger.say("New password sent to " + email);
    }), 100);
  };
});

angular.module("barachiel.auth.services", []).factory("AuthService", function($http, _, utils, $log, StorageService, BASE_URL) {
  var set_user, _is_auth;
  _is_auth = Boolean(StorageService.get('user'));
  set_user = function(user) {
    return StorageService.set('user', JSON.stringify(user));
  };
  return {
    Authenticate: function(credentials) {
      return $http({
        method: 'POST',
        url: BASE_URL + '/auth/login/',
        data: utils.to_form_params(credentials),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        }
      }).success(function(user, status, headers, config) {
        set_user(user);
        _is_auth = true;
        return user;
      }).error(function(data) {
        return $log.error("Couldn't Authenticate: " + data);
      });
    },
    Logout: function() {
      StorageService.delete_all();
      return $http.get(BASE_URL + '/auth/logout/', {}).success(function() {
        return _is_auth = false;
      }).error(function(data) {
        return $log.error("Couldn't Logout: " + data);
      });
    },
    Signup: function(credentials) {
      return $http({
        method: 'POST',
        url: BASE_URL + '/auth/signup/',
        data: utils.to_form_params(credentials),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        }
      }).success(function(user, status, headers, config) {
        set_user(user);
        _is_auth = true;
        return user;
      }).error(function(data) {
        return $log.error("Couldn't Signup: " + data);
      });
    },
    isAuthenticated: function(http_check) {
      if (http_check == null) {
        http_check = false;
      }
      if (_is_auth && http_check) {
        $http.get(BASE_URL + '/users/me').success(function(user) {
          return set_user(user);
        });
      }
      return _is_auth;
    },
    state_requires_auth: function($state) {
      return !angular.isDefined($state.authenticate) || $state.authenticate;
    }
  };
}).factory("authHttpResponseInterceptor", function($q, $injector) {
  return {
    response: function(response) {
      return response || $q.when(response);
    },
    responseError: function(rejection) {
      if (rejection.status === 401) {
        console.warn("Response Error 401", rejection);
        $injector.get('AuthService').Logout();
        $injector.get('$state').transitionTo("signup");
      }
      return $q.reject(rejection);
    }
  };
});

angular.module("barachiel.device.services", []).factory("StorageService", function($window) {
  return {
    all: function() {
      return $window.localStorage;
    },
    get: function(key) {
      return $window.localStorage[key];
    },
    set: function(key, value) {
      return $window.localStorage[key] = value;
    },
    "delete": function(key) {
      return delete $window.localStorage[key];
    },
    delete_all: function() {
      return delete $window.localStorage.clear();
    }
  };
});
