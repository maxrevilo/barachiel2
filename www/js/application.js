angular.module("barachiel", ["barachiel.config", "ngCordova", "ngAnimate", "ionic", "underscore", "angular-progress-arc", "pascalprecht.translate", "barachiel.util.services", "barachiel.device.services", "barachiel.auth.services", "barachiel.auth.controllers", "barachiel.directives", "barachiel.controllers", "barachiel.services"]).run(function($ionicPlatform, $rootScope, $state, AuthService) {
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
}).controller("RadarCtrl", function($scope, $ionicPlatform, Users, $http, BASE_URL, $window) {
  $scope.users = Users.all();
  return $scope.doRefresh = function() {
    $http.get(BASE_URL + '/users/me/');
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
}).controller("ProfileCtrl", function($scope, $stateParams, $ionicActionSheet, l, User, MediaManipulation, $timeout) {
  $scope.profile = {
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
  $scope.uploadingPicture = {
    'on': false,
    'progress': 0,
    'start': function() {
      this.on = true;
      return this.progress = 0;
    },
    'stop': function() {
      return this.on = false;
    },
    'set': function(progress) {
      return this.progress = progress;
    }
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
          $scope.uploadingPicture.start();
          return User.change_image(imageURI);
        }).then((function(result) {
          $scope.uploadingPicture.stop();
          return console.log("Change Image Success");
        }), null, (function(progressEvent) {
          var progress;
          if (progressEvent.lengthComputable) {
            progress = progressEvent.loaded / progressEvent.total;
            console.log("Uploading Progress: " + progress);
            return $scope.uploadingPicture.progress = progress;
          } else {
            console.log("Uploading Progress: Non computable advance.");
            return $scope.uploadingPicture.progress += 0.05;
          }
        }))["catch"]((function(err) {
          $scope.uploadingPicture.stop();
          throw new Error("Error changing image " + err);
        }));
        return true;
      }
    });
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
}).factory("User", function(BASE_URL, $q, MediaManipulation, $window) {
  return {
    change_image: function(image_uri) {
      return MediaManipulation.upload_file(BASE_URL + '/multimedia/user/', image_uri);
    }
  };
});

angular.module("barachiel.util.services", []).factory("Messenger", function($window, $ionicPopup, l) {
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
}).factory("l", function(_) {
  return function(text, args) {
    return text;
  };
}).factory("MediaManipulation", function(_, $q, $window, $ionicPlatform, $cordovaCamera, $cordovaFile) {
  var Camera, ImageResizer, imageResizer;
  Camera = $window.Camera;
  imageResizer = $window.imageResizer;
  ImageResizer = $window.ImageResizer;
  return {
    get_pitcute: function(user_camera) {
      var options, sourceType;
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
      return $cordovaCamera.getPicture(options);
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
