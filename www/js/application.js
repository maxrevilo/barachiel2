angular.module("barachiel", ["barachiel.config", "ngCordova", "restangular", "ionic", "ngAnimate", "underscore", "angular-progress-arc", "barachiel.i18n", "barachiel.utils.directives", "barachiel.utils.services", "barachiel.device.services", "barachiel.auth.services", "barachiel.auth.controllers", "barachiel.directives", "barachiel.filters", "barachiel.controllers", "barachiel.services"]).run(function($ionicPlatform, $rootScope, $state, $window, AuthService) {
  $window['$rootScope'] = $rootScope;
  return $ionicPlatform.ready(function() {
    console.log("Barachiel running on " + window.platform_service_definition.name);
    if (window.cordova && window.cordova.plugins.Keyboard) {
      cordova.plugins.Keyboard.hideKeyboardAccessoryBar(false);
    }
    if (window.StatusBar) {
      StatusBar.styleDefault();
    }
    if (AuthService.state_requires_auth($state.current) && !AuthService.isAuthenticated(true)) {
      $state.transitionTo("st.signup");
    }
    return $rootScope.$on("$stateChangeStart", function(event, toState, toParams, fromState, fromParams) {
      if (AuthService.state_requires_auth(toState) && !AuthService.isAuthenticated()) {
        $state.transitionTo("st.signup");
        event.preventDefault();
      }
    });
  });
}).config(function($stateProvider, $urlRouterProvider, i18nProvider, $httpProvider, RestangularProvider, BASE_URL) {
  $httpProvider.interceptors.push('authHttpResponseInterceptor');
  RestangularProvider.setBaseUrl(BASE_URL);
  RestangularProvider.setRequestSuffix('/');
  i18nProvider.lang('en');
  $stateProvider.state("st", {
    abstract: true,
    template: '<ui-view/>',
    resolve: {
      i18n: function(i18n) {
        return i18n.loadTranslations("https://dl.dropboxusercontent.com/u/4461171/web/en.json");
      }
    }
  }).state("st.login", {
    url: "/login",
    templateUrl: "templates/login.html",
    controller: "LoginCtrl",
    authenticate: false
  }).state("st.forgot_password", {
    url: "/forgot_password",
    templateUrl: "templates/forgot_password.html",
    controller: "ForgotPasswordCtrl",
    authenticate: false
  }).state("st.signup", {
    url: "/signup",
    templateUrl: "templates/signup.html",
    controller: "SignupCtrl",
    authenticate: false
  }).state("st.tutorial", {
    url: "/tutorial",
    templateUrl: "templates/tutorial.html",
    controller: "TutorialCtrl",
    authenticate: false
  }).state("st.tab", {
    url: "/tab",
    abstract: true,
    templateUrl: "templates/tabs.html",
    controller: 'TabCtrl'
  }).state("st.tab.radar", {
    url: "/radar",
    views: {
      "tab-radar": {
        templateUrl: "templates/tab-radar.html",
        controller: "RadarCtrl"
      }
    }
  }).state("st.tab.radar-user-detail", {
    url: "/radar/user/:userId",
    views: {
      "tab-radar": {
        templateUrl: "templates/user-detail.html",
        controller: "UserDetailCtrl"
      }
    }
  }).state("st.tab.wavers", {
    url: "/wavers",
    views: {
      "tab-wavers": {
        templateUrl: "templates/tab-wavers.html",
        controller: "WaversCtrl"
      }
    }
  }).state("st.tab.waver-detail", {
    url: "/waver/:waverId",
    views: {
      "tab-wavers": {
        templateUrl: "templates/waver-detail.html",
        controller: "WaverDetailCtrl"
      }
    }
  }).state("st.tab.waver-user-detail", {
    url: "/waver/user/:userId",
    views: {
      "tab-wavers": {
        templateUrl: "templates/user-detail.html",
        controller: "UserDetailCtrl"
      }
    }
  }).state("st.tab.profile", {
    url: "/profile",
    views: {
      "tab-profile": {
        templateUrl: "templates/tab-profile.html",
        controller: "ProfileCtrl"
      }
    }
  });
  return $urlRouterProvider.otherwise("/tab/radar");
});

var config, config_module;

config = {
  APP_NAME: 'Waving',
  BASE_URL: 'https://barachiel.herokuapp.com'
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
    return $state.go("st.tutorial");
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
    return $state.go("st.tab.radar");
  };
}).controller("RadarCtrl", function($scope, l, Users) {
  $scope.state = 'loading';
  $scope.error = {};
  $scope.refreshUsers = function() {
    var promise;
    promise = null;
    if (($scope.users != null) && $scope.users.length > 0) {
      promise = $scope.users.getList();
    } else {
      promise = Users.all();
      $scope.users = promise.$object;
    }
    return promise.then(function() {
      return $scope.state = 'ready';
    }, function(jqXHR) {
      $scope.state = 'error';
      return $scope.error.message = (function() {
        switch (jqXHR.status) {
          case 0:
            return l("%global.error.server_not_found");
          default:
            return jqXHR.statusText;
        }
      })();
    });
  };
  $scope.doRefresh = function() {
    return $scope.refreshUsers()["finally"](function() {
      return $scope.$broadcast("scroll.refreshComplete");
    });
  };
  $scope.$on("REFRESH_RADAR", function(ev, data) {
    return $scope.refreshUsers();
  });
  return $scope.refreshUsers();
}).controller("WaversCtrl", function($scope, Users) {
  var me;
  me = Users.me();
  $scope.wavers = me.likes_to;
  return me.refreshLikesTo();
}).controller("WaverDetailCtrl", function(_, $scope, $stateParams, Likes) {
  $scope.waver = {
    id: 0,
    name: 'Scruff McGruff',
    user_id: 0
  };
  return $scope.waver.__safe__name = _.escape($scope.waver.name);
}).controller("ProfileCtrl", function($rootScope, $scope, $stateParams, $state, $ionicActionSheet, l, AuthService, Users, MediaManipulation, $timeout) {
  var user;
  user = Users.me(true);
  $scope.profile = user;
  if ($rootScope.uploadingPicture == null) {
    $rootScope.uploadingPicture = {
      'on': false,
      'progress': 0,
      'image': null,
      'start': function(image) {
        this.image = image;
        this.on = true;
        return this.progress = 0;
      },
      'stop': function() {
        this.image = null;
        return this.on = false;
      },
      'set': function(progress) {
        return this.progress = progress;
      },
      'increment': function(inc) {
        return this.progress += inc || 0.05;
      },
      'finish': function() {
        this.progress = 1;
        return $timeout(((function(_this) {
          return function() {
            return _this.stop();
          };
        })(this)), 500);
      },
      'fail': function() {
        return this.stop();
      }
    };
  }
  $scope.uploadingPicture = $rootScope.uploadingPicture;
  $scope.logout = function() {
    return AuthService.Logout().then(function() {
      return $state.go("st.signup");
    });
  };
  return $scope.takePicture = function() {
    return $ionicActionSheet.show({
      buttons: [
        {
          text: l("Photoalbun")
        }, {
          text: l("Camera")
        }
      ],
      titleText: l("How to get the image"),
      cancelText: l("Cancel"),
      cancel: function() {
        return true;
      },
      buttonClicked: function(index) {
        MediaManipulation.get_pitcute(index === 1).then(function(imageURI) {
          $scope.uploadingPicture.start(imageURI);
          return user.change_image(imageURI);
        }).then((function(result) {
          $scope.uploadingPicture.finish();
          return console.log("Change Image Success");
        }), null, (function(progressEvent) {
          if (progressEvent.lengthComputable) {
            return $scope.uploadingPicture.set(progressEvent.loaded / progressEvent.total);
          } else {
            return $scope.uploadingPicture.increment();
          }
        }))["catch"]((function(err) {
          $scope.uploadingPicture.fail();
          throw new Error("Error changing image " + err);
        }));
        return true;
      }
    });
  };
}).controller("UserDetailCtrl", function($scope, $stateParams, Users) {
  var userPromise;
  userPromise = Users.get($stateParams.userId);
  return $scope.user = userPromise.$object;
});

angular.module("barachiel.directives", []).directive('ygUserItem', function() {
  return {
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
}).directive('ygWaverItem', function() {
  return {
    scope: {
      waver: '='
    },
    controller: function($scope, $element, $attrs, $transclude) {
      return $element.on('click', function() {
        return window.location.hash = $attrs.href;
      });
    },
    restrict: 'AEC',
    templateUrl: 'templates/waver-item.html'
  };
});

angular.module("barachiel.filters", []).filter("byDistance", function(_) {
  return function(users, min, max) {
    return _(users).filter(function(user) {
      return (user.d || 0) >= min && (user.d || 0) < max;
    });
  };
});

angular.module("barachiel.services", []).factory("Likes", function(Restangular, Users) {
  var Likes;
  Likes = Restangular.service('likes');
  Likes.toMe = function() {
    return this.getList();
  };
  Likes.get = function(id) {
    return this.one(id).get();
  };
  Restangular.extendModel("likes", function(waver) {
    waver.s_picture = Users.getPicture(waver.user);
    waver.user = Restangular.restangularizeElement('', waver.user, 'users', {});
    return waver;
  });
  return Likes;
}).factory("Users", function(BASE_URL, _, l, $injector, Restangular, AuthService, MediaManipulation) {
  var Likes, Users;
  Likes = null;
  Users = Restangular.service('users');
  Users.all = function() {
    return this.getList();
  };
  Users.get = function(id) {
    return this.one(id).get();
  };
  Users.me = function(force_request) {
    var promise, userData;
    promise = null;
    if (this._me == null) {
      userData = AuthService.GetUser();
      if (userData != null) {
        this.set_me(userData);
      } else {
        throw new Error("Local user not found");
      }
    }
    if (force_request) {
      this._me.get();
    }
    return this._me;
  };
  Users.set_me = function(rawUserJSON) {
    return this._me = Restangular.restangularizeElement('', rawUserJSON, 'users', {});
  };
  Users.getPicture = function(user) {
    var default_img, sex;
    if (user && (user.picture != null)) {
      return user.picture;
    } else {
      sex = (user && user.sex ? user.sex : 'u').toLowerCase();
      default_img = 'img/avatars/' + sex + '_anonym.png';
      return {
        'id': -1,
        'type': "I",
        'uploader_id': -1,
        'xBig': default_img,
        'xFull': default_img,
        'xLit': default_img
      };
    }
  };
  Users.SentimentalStatus = {
    DontSay: 'U',
    Single: 'S',
    Married: 'M',
    InRelationShip: 'R'
  };
  Users.Sex = {
    DontSay: 'U',
    Male: 'M',
    Female: 'F'
  };
  Users.RelInterest = {
    DontSay: 'U',
    Male: 'M',
    Female: 'F',
    Both: 'B',
    Firends: 'R'
  };
  Users.ToTextMappings = {
    SentimentalStatus: {},
    Sex: {},
    RelInterest: {}
  };
  Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.DontSay] = l("%global.unrevealed");
  Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.Single] = l("%global.sstatus.single");
  Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.Married] = l("%global.sstatus.married");
  Users.ToTextMappings.SentimentalStatus[Users.SentimentalStatus.InRelationShip] = l("%global.sstatus.in_a_relationship");
  Users.ToTextMappings.Sex[Users.Sex.DontSay] = l("%global.unrevealed");
  Users.ToTextMappings.Sex[Users.Sex.Male] = l("%global.gender.M");
  Users.ToTextMappings.Sex[Users.Sex.Female] = l("%global.gender.F");
  Users.ToTextMappings.RelInterest[Users.RelInterest.DontSay] = l("%global.unrevealed");
  Users.ToTextMappings.RelInterest[Users.RelInterest.Male] = l("%global.rel_interest.male");
  Users.ToTextMappings.RelInterest[Users.RelInterest.Female] = l("%global.rel_interest.female");
  Users.ToTextMappings.RelInterest[Users.RelInterest.Both] = l("%global.rel_interest.both");
  Users.ToTextMappings.RelInterest[Users.RelInterest.Friends] = l("%global.rel_interest.friends");
  Restangular.extendModel("users", function(user) {
    Likes = $injector.get("Likes");
    user.change_image = function(image_uri) {
      return MediaManipulation.upload_file(BASE_URL + '/multimedia/user/', image_uri).then(((function(_this) {
        return function(result) {
          return _this.picture = JSON.parse(result.response);
        };
      })(this)), ((function(_this) {
        return function(error) {
          return error;
        };
      })(this)));
    };
    user.sentimentalStatusHR = function() {
      return Users.ToTextMappings.SentimentalStatus[this.sentimental_status];
    };
    user.sexHR = function() {
      return Users.ToTextMappings.SentimentalStatus[this.sex];
    };
    user.relInterestHR = function() {
      return Users.ToTextMappings.SentimentalStatus[this.r_interest];
    };
    user.refreshLikesTo = function() {
      var promise;
      promise = Likes.toMe();
      return promise.then(function(likes) {
        user.likes_to.length = 0;
        Array.prototype.push.apply(user.likes_to, likes);
        return likes;
      });
    };
    if (user.liked != null) {
      user.likes_to = Restangular.restangularizeCollection('', user.liked, 'likes', {});
    }
    if (user.likes != null) {
      user.likes_from = Restangular.restangularizeCollection('', user.likes, 'likes', {});
    }
    user.s_picture = Users.getPicture(user);
    return user;
  });
  return Users;
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
        return $state.go("st.tutorial");
      }, function(jqXHR) {
        Loader.hide($scope);
        switch (jqXHR.status) {
          case 0:
            return utils.translateAndSay("%global.error.server_not_found");
          case 403:
            return utils.translateAndSay("%global.error.invalid_register_form_{0}", {
              'val': jqXHR.responseText
            });
          default:
            return utils.translateAndSay("%global.error.std_{0}", {
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
        return $state.go("st.tab.radar");
      }, function(jqXHR) {
        Loader.hide($scope);
        switch (jqXHR.status) {
          case 0:
            return utils.translateAndSay("%global.error.server_not_found");
          case 403:
            return utils.translateAndSay("%global.error.invalid_email_or_passwd");
          default:
            return utils.translateAndSay("%global.error.std_{0}", {
              'val': utils.parseFormErrors(jqXHR.data)
            });
        }
      });
    }
  };
}).controller("ForgotPasswordCtrl", function($scope, $state, AuthService, Loader, utils) {
  return $scope.reset_password = function(email) {
    Loader.show($scope);
    return AuthService.resetPasswordOf(email).then(function() {
      Loader.hide($scope);
      return utils.translateAndSay("%pw_reset.success");
    }, function(jqXHR) {
      Loader.hide($scope);
      switch (jqXHR.status) {
        case 0:
          return utils.translateAndSay("%global.error.server_not_found");
        default:
          return utils.translateAndSay("%global.error.std_{0}", {
            'val': utils.parseFormErrors(jqXHR.data)
          });
      }
    });
  };
});

angular.module("barachiel.auth.services", []).factory("AuthService", function($rootScope, $http, $log, _, utils, StorageService, BASE_URL) {
  var _is_auth, _set_user, _unset_user;
  _is_auth = function() {
    var raw_ls_user;
    if ($rootScope.user != null) {
      return true;
    } else {
      raw_ls_user = StorageService.get('user');
      if (raw_ls_user != null) {
        $rootScope.user = JSON.parse(raw_ls_user);
        return true;
      } else {
        return false;
      }
    }
  };
  _set_user = function(user) {
    StorageService.set('user', JSON.stringify(user));
    return $rootScope.user = user;
  };
  _unset_user = function() {
    $rootScope.user = null;
    return StorageService["delete"]('user');
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
        return _set_user(user);
      }).error(function(data) {
        return $log.error("Couldn't Authenticate: " + data);
      });
    },
    Logout: function() {
      return $http.get(BASE_URL + '/auth/logout/', {}).success(function() {
        return _unset_user();
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
        return _set_user(user);
      }).error(function(data) {
        return $log.error("Couldn't Signup: " + data);
      });
    },
    GetUser: function() {
      return $rootScope.user;
    },
    isAuthenticated: function(http_check) {
      if (http_check == null) {
        http_check = false;
      }
      if (_is_auth() && http_check) {
        $http.get(BASE_URL + '/users/me/').success(function(user) {
          return _set_user(user);
        });
      }
      return _is_auth();
    },
    resetPasswordOf: function(user_email) {
      return $http({
        method: 'POST',
        url: BASE_URL + '/auth/reset_password/',
        data: utils.to_form_params({
          "email": user_email
        }),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        }
      });
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
        $injector.get('$state').transitionTo("st.signup");
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

angular.module("barachiel.i18n.directives", []).directive('translate', function(l) {
  return {
    scope: {
      user: '='
    },
    restrict: 'A',
    link: function(scope, iElement, iAttrs) {
      return iElement.text(l(iElement.text().trim()));
    }
  };
});

angular.module("barachiel.i18n.filters", []).filter("translate", function(l) {
  return function(text, args) {
    return l(text, args);
  };
});

angular.module("barachiel.i18n", ['barachiel.i18n.directives', 'barachiel.i18n.services', 'barachiel.i18n.filters']).provider("i18n", function() {
  var lang, translations;
  lang = 'en';
  translations = {
    'hola': 'hello'
  };
  this.lang = function(val) {
    if (val != null) {
      return lang = val;
    }
  };
  this.translations = function(val) {
    if (val != null) {
      return lang = val;
    }
  };
  this.$get = [
    '$http', function($http) {
      return {
        lang: lang,
        translations: translations,
        loadTranslations: function(url) {
          return $http.get(url).success((function(_this) {
            return function(result) {
              return _this.translations = JSON.parse(JSON.stringify(result));
            };
          })(this));
        },
        translate: function(key, args) {
          var a, arg, value, _i, _len;
          if (!(typeof args === "object" && args instanceof Array)) {
            if (typeof args === "string") {
              args = [args];
            } else {
              args = [];
            }
          }
          value = this.translations[key];
          if (value == null) {
            value = key;
          }
          for (a = _i = 0, _len = args.length; _i < _len; a = ++_i) {
            arg = args[a];
            value = value.replace('{#{a}}', arg);
          }
          return value;
        }
      };
    }
  ];
});

angular.module("barachiel.i18n.services", []).factory("translate", function(i18n) {
  return function(text, args) {
    return i18n.translate(text, args);
  };
}).factory("l", function(translate) {
  return function(text, args) {
    return translate(text, args);
  };
});

angular.module("barachiel.utils.directives", []);

angular.module("barachiel.utils.services", []).factory("Messenger", function($window, $ionicPopup, l) {
  return {
    say: function(message) {
      return $ionicPopup.alert({
        title: l("alert"),
        template: message
      });
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
}).factory("utils", function(_, l, Messenger) {
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
      return Messenger.say(l(tkey, args));
    },
    parseFormErrors: function(errors) {
      return (_(errors).reduce((function(arr, error) {
        return arr.concat(error[0]);
      }), [])).join(', ');
    }
  };
}).factory("MediaManipulation", function(_, $q, $window, $ionicPlatform, $cordovaCamera, $cordovaFile) {
  return {
    get_pitcute: function(user_camera) {
      var deferred;
      deferred = $q.defer();
      $ionicPlatform.ready(function() {
        var Camera, options, sourceType;
        Camera = $window.Camera;
        sourceType = user_camera ? Camera.PictureSourceType.CAMERA : Camera.PictureSourceType.PHOTOLIBRARY;
        options = {
          'quality': 75,
          'destinationType': Camera.DestinationType.FILE_URI,
          'sourceType': sourceType,
          'allowEdit': true,
          'encodingType': Camera.EncodingType.JPEG,
          'targetWidth': 800,
          'targetHeight': 800,
          'saveToPhotoAlbum': false
        };
        return $cordovaCamera.getPicture(options).then((function(arg) {
          return deferred.resolve(arg);
        }), (function(arg) {
          return deferred.reject(arg);
        }), (function(arg) {
          return deferred.notify(arg);
        }));
      });
      return deferred.promise;
    },
    upload_file: function(url, file_uri) {
      var options;
      options = {
        'chunkedMode': true
      };
      return $cordovaFile.uploadFile(url, file_uri, options);
    },
    resize_image: function(image_uri, width, height) {
      var deferred;
      deferred = $q.defer();
      $ionicPlatform.ready(function() {
        var ImageResizer, imageResizer;
        imageResizer = $window.imageResizer;
        ImageResizer = $window.ImageResizer;
        return imageResizer.getImageSize((function(size) {
          console.log("Original image size: " + size.width + "x" + size.height);
          if (size.width > width || size.height > height) {
            return imageResizer.resizeImage((function(result) {
              return deferred.resolve(result.imageData);
            }), (function(error) {
              return deferred.reject("Not able to resize image: " + error);
            }), image_uri, 800, 800, {
              'imageDataType': ImageResizer.IMAGE_DATA_TYPE_URL,
              'resizeType': ImageResizer.RESIZE_TYPE_MAX_PIXEL,
              'format': ImageResizer.FORMAT_JPG,
              'quality': 100,
              'pixelDensity': false,
              'storeImage': false
            });
          } else {
            return deferred.resolve(image_uri);
          }
        }), (function(error) {
          return deferred.reject("Not able to get the image size: " + error);
        }), image_uri);
      });
      return deferred.promise;
    }
  };
});
