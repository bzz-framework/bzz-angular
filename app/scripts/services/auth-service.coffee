'use strict'

options =
  googleClientId: null
  googleApiKey: null
  googleScopes: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
  bzzApiUrl: 'http://localhost:2368/'
  redirectWhenLogin: '/'
  loginPage: '/login'

class AuthService

  constructor: (@options, @http, @rootScope, @location, @GooglePlus) ->
    @bindEvents()

  bindEvents: ->
    @rootScope.$on('unauthorizedRequest', (event, callback) =>
      @signOut(callback)
    )
    @rootScope.$on('$locationChangeStart', (event, next, prev, callback) =>
      @checkAuthentication(callback)
    )

  responseInterceptor: ($q) ->
    onError = (response) ->
      if response.status is 401
        @rootScope.$broadcast('unauthorizedRequest')
      $q.reject response

    return (promise) ->
      promise.then(((response) -> response), onError)

  setSignIn: (provider, accessToken) ->
    path = '/auth/signin/'
    @http.post(@options['bzzApiUrl'] + path,
      provider: provider
      access_token: accessToken
    )

  setSignOut: ->
    path = '/auth/signout/'
    @http.post(@options['bzzApiUrl'] + path, '')

  getAuthMe: ->
    path = '/auth/me/'
    @http.get(@options['bzzApiUrl'] + path)

  signOut: (callback) ->
    if !@isAuthenticated
      @setSignOut().success((response) =>
        if response.loggedOut
          @isAuthenticated = false
          @userData = null
          @location.url @options['loginPage']
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

  googleLogin: (callback) =>
    @GooglePlus.login().then((authResult) =>
      @setSignIn('google', authResult.access_token).then((response) =>
        if response.data.authenticated
          @isAuthenticated = true
          @location.url @options['redirectWhenLogin']
          if callback then callback()
        else
          @signOut(callback)
      , =>
        @signOut(callback)
      )
    , (err) =>
      @signOut(callback)
    )

angular.module('bzz.auth', ['googleplus'])
  .provider('AuthService', (GooglePlusProvider) ->
    @init = (customOptions) ->
      @options = angular.extend(options, customOptions)
      @initializeGooglePlus(@options)  # if google enabled

    @initializeGooglePlus = (options) ->
      GooglePlusProvider.init
        clientId: options['googleClientId']
        apiKey: options['googleApiKey']
        scopes: options['googleScopes']

    @$get = ($http, $rootScope, $location, GooglePlus) ->
      new AuthService(@options, $http, $rootScope, $location, GooglePlus)

    return
  )
