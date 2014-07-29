'use strict'

###*
 # @ngdoc overview
 # @name bzzAngularApp
 # @description
 # # bzzAngularApp
 #
 # Main module of the application.
###
angular
  .module('bzzAngularApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'googleplus'
  ])
  .config ($routeProvider, GooglePlusProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/about',
        templateUrl: 'views/about.html'
        controller: 'AboutCtrl'
      .otherwise
        redirectTo: '/'

    GooglePlusProvider.init
      clientId: 'YOUR_CLIENT_ID',
      apiKey: 'YOUR_API_KEY'

