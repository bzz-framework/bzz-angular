'use strict'

###*
 # @ngdoc function
 # @name bzzAngularApp.controller:AboutCtrl
 # @description
 # # AboutCtrl
 # Controller of the bzzAngularApp
###
angular.module('bzzAngularApp')
  .controller 'AboutCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
