'use strict'

###*
 # @ngdoc function
 # @name bzzAngularApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the bzzAngularApp
###
angular.module('bzzAngularApp')
  .controller 'MainCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
