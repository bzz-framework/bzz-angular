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
    'bzz.auth'
  ])
  .config ($routeProvider, AuthServiceProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/about',
        templateUrl: 'views/about.html'
        controller: 'AboutCtrl'
      .otherwise
        redirectTo: '/'

    AuthServiceProvider.init
      googleClientId: '840338438074-v3qa8cqcibi9novkq2qgv0uvb768g6c5.apps.googleusercontent.com'
      googleApiKey: 'AIzaSyAuTg2K66eFEvxWFpOhOMU_UeE7dq71pMs'
      googleScopes: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
      bzzApiUrl: 'http://local.globoi.com:2368/api'
      redirectWhenLogin: '/'
      loginPage: '/login'

  .factory "httpResponseInterceptor", ($q, AuthService) ->
    AuthService.responseInterceptor($q)
