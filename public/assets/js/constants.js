// You can add any other environment you want
angular.module("MyAngularConfig.development", []).constant('Config', {
  //configuration options for development environment like below
  //api_url: 'http://localhost:4567',
});

angular.module("MyAngularConfig.production", []).constant('Config', {
  //configuration options for production environment like below
  //api_url: 'http://yd9.net',
});
