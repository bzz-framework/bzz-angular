'use strict'


class AuthService

  constructor: (@http, @rootScope, @location, @GooglePlus) ->
    @bzzApiUrl = 'http://local.bzz.com:9000'
    @bindEvents()

  bindEvents: ->
    @rootScope.$on('unauthorizedRequest', (event, callback) =>
      @signOut(callback)
    )
    @rootScope.$on('$locationChangeStart', (event, next, prev, callback) =>
      @checkAuthentication(callback)
    )

  setSignIn: (provider, accessToken) ->
    path = '/auth/signin/'
    @http.post(@bzzApiUrl + path,
      provider: provider
      access_token: accessToken
    )

  setSignOut: ->
    path = '/auth/signout/'
    @http.post(@bzzApiUrl + path, '')

  getAuthMe: ->
    path = '/auth/me/'
    @http.get(@bzzApiUrl + path)

  signOut: (callback) ->
    if !@isAuthenticated
      @setSignOut().success((response) =>
        if response.loggedOut
          @isAuthenticated = false
          @userData = null
          @location.url '/login'
          if callback then callback()
      ).error((response) =>
        console.log 'Failed to signOut: ', response
      )
    else if callback
      callback()

  checkAuthentication: (callback) ->
    @getAuthMe().success((response) =>
      if response.authenticated
        @isAuthenticated = response.authenticated
        @userData = response.userData
        if callback then callback()
      else
        @signOut(callback)
    ).error((response) =>
      console.log 'Failed to check Authentication:', response
    )

  googleLogin: (callback) ->
    @googlePlus.login().then((authResult) =>
      @setSignIn('GooglePlus', authResult.access_token).then((response) =>
        if response.data.authenticated
          @isAuthenticated = true
          @location.url "/"
          if callback then callback()
        else
          @signOut(callback)
      , =>
        @signOut(callback)
      )
    , (err) =>
      @signOut(callback)
    )

angular.module('bzzAngularApp')
  .service('AuthService', ($http, $rootScope, $location, GooglePlus) ->
    new AuthService($http, $rootScope, $location, GooglePlus)
  )
