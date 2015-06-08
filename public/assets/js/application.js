var MyAngularApp = angular.module("MyAngularApp", [
  'ngResource',
  'ngRoute',
  'MyAngularControllers',
  // Uncomment the line for appropriate environment usage
  //'MyAngularConfig.development',
  'MyAngularConfig.production',
  'MyAngularServices',
]);

// Example routing
MyAngularApp.config(['$routeProvider',
  function($routeProvider){
    $routeProvider.
    when('/', {
      templateUrl: 'partials/hello_world.html',
      controller: 'MyHelloWordController'
    }).
    when('/404', {
      templateUrl: 'partials/404.html',
    }).
    when('/500', {
      templateUrl: 'partials/500.html',
    }).
    otherwise({
      redirectTo: '/'
    });
  }
]);

// Capture keydown events
/*
MyAngularApp.run(['$rootScope', '$document',
  function($rootScope, $document){
    var handleKeyDown = function(event){
      $rootScope.$apply(function(){
        switch(true){
          case ($rootScope.listen && event.which >= 65 && event.which <= 90):
            // KeyCode (event.which) will be second argument to listner function
            $rootScope.$broadcast('key.alphabet', event.which);
            break;
          default:
            break;
        };
      });
    };

    angular.element($document).bind('keydown', handleKeyDown);
    $rootScope.$on('destroy', function(){
      angular.element($document).unbind('keydown', handleKeyDown);
    });
  }
]);
*/
