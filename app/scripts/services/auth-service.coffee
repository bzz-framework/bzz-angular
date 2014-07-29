'use strict'

class AuthService

  constructor: (@http, @rootScope, @location, @GooglePlus) ->
    @bzzApiUrl = 'http://local.bzz.com:9000'
    @bindEvents()

  bindEvents: ->
    @rootScope.$on('unauthorizedRequest', (event, callback) =>
      @logout(callback)
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

  logout: (callback) ->
    if !@isLoggedIn
      @setSignOut().success((response) =>
        if response.loggedOut
          @isLoggedIn = false
          @userData = null
          @location.url '/login'
          if callback then callback()
      ).error((response) =>
        console.log 'Failed to Logout: ', response
      )
    else if callback
      callback()

  checkAuthentication: (callback) ->
    @getAuthMe().success((response) =>
      if response.authenticated
        @isLoggedIn = response.authenticated
        @userData = response.userData
        if callback then callback()
      else
        @logout(callback)
    ).error((response) =>
      console.log 'Failed to check Authentication:', response
    )

  googleLogin: (callback) ->
    @googlePlus.login().then((authResult) =>
      @setSignIn('GooglePlus', authResult.access_token).then((response) =>
        if response.data.authenticated
          @isLoggedIn = true
          @location.url "/"
          if callback then callback()
        else
          @logout(callback)
      , =>
        @logout(callback)
      )
    , (err) =>
      @logout(callback)
    )

  #logoutIfNotAuthenticated: (callback) ->
    #if !@isLoggedIn then @logout(callback)

  #redirectIfAuthenticated: (callback) ->
    #if @isLoggedIn
      #@location.url '/'
      #callback()

angular.module('bzzAngularApp')
  .service('AuthService', ($http, $rootScope, $location, GooglePlus) ->
    new AuthService($http, $rootScope, $location, GooglePlus)
  )
