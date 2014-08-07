'use strict'

###*
 # @ngdoc function
 # @name directivesApp.controller:TestcontrollerCtrl
 # @description
 # # TestcontrollerCtrl
 # Controller of the directivesApp
###
angular.module('directivesApp')
  .controller 'TestcontrollerCtrl', ($scope) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
