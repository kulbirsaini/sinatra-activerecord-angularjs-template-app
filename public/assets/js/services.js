var MyAngularServices = angular.module("MyAngularServices", []);

MyAngularServices.factory("MyService", ["$resource", "Config",
  function($resource, Config){

    // Use config options set in constants.js here.
    var resource = $resource(Config.api_url, { id: '@id' }, {
      get: { method: 'GET' },
      post: { method: 'POST' },
      query: { method: 'GET', isArray: true },
    });

    return resource;
  }
]);
