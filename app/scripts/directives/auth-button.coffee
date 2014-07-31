'use strict'

class AuthButtonCtrl

  constructor: (@scope, @provider, @AuthService) ->

  login: ->
    if @provider == 'google'
      @AuthService.googleLogin()
    else
      console.log 'Invalid provider'

angular.module('bzz.auth')
  .directive('authButton', (AuthService) ->
    templateUrl: 'views/directives/auth-button.html'
    restrict: 'E'
    link: (scope, element, attributes) ->
      console.log 'Instantiate bzzAuthButton'
      scope.model = new AuthButtonCtrl(
        scope, attributes['provider'], AuthService
      )
  )
