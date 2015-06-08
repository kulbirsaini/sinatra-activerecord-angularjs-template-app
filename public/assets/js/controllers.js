var MyAngularControllers = angular.module("MyAngularControllers", []);

MyAngularControllers.controller('MyHelloWordController', ['$scope',
  function($scope){
    $scope.initializeData = function(){
      $scope.hello_message = 'Hello World!';
    };

    $scope.initializeData();
  }
]);
