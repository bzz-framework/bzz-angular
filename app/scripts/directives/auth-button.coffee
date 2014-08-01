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
    template: '''
      <a href="javascript:;" class="{{ model.provider }}-login auth-button" ng-click="model.login()">
      <span class="icon"></span><span class="text">Entrar com {{ model.provider }}</span></a>
    '''
    restrict: 'E'
    transclude: true
    link: (scope, element, attributes) ->
      scope.model = new AuthButtonCtrl(
        scope, attributes['provider'], AuthService
      )
  )
