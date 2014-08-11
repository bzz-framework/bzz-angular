'use strict'

options =
  googleClientId: null
  googleApiKey: null
  googleScopes: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
  bzzApiUrl: 'http://localhost:2368/'
  redirectWhenLogin: '/'
  loginPage: '/login'

class AuthService

  constructor: (@options, @http, @rootScope, @location, @route, @GooglePlus) ->
    @baseLen = @_getBaseLen()
    @redirectUrl = @_getOption('redirectWhenLogin')
    @bindEvents()

  _getBaseLen: ->
    baseLen = @location.absUrl().length - @location.url().length
    if @location.url() == '' then baseLen - 1 else baseLen

  _getOption: (key) ->
    if @options? then @options[key] else options[key]

  _getRelativeUrl: (fullUrl) ->
    if fullUrl? then fullUrl.substring(@baseLen) else fullUrl

  bindEvents: ->
    @rootScope.$on 'unauthorizedRequest', (event, callback) =>
      @signOut(callback)

    @rootScope.$on '$locationChangeStart', (event, next, prev, callback) =>
      login_path = @_getOption('loginPage')
      if @_getRelativeUrl(next) == login_path and @_getRelativeUrl(prev) != login_path
        @redirectUrl = @_getRelativeUrl(prev)
      @rootScope.$broadcast('$locationChangeSuccess', next, prev, callback)

    @rootScope.$on '$locationChangeSuccess', (event, current, previous, callback) =>
      if @route.current.requiresAuthentication
        @checkAuthentication(callback if typeof(callback) == 'function')
      else
        callback() if typeof(callback) == 'function'

  getAuthMe: ->
    path = '/auth/me/'
    @http.get(@_getOption('bzzApiUrl') + path)

  checkAuthentication: (callback) ->
    @getAuthMe().success((response) =>
      if response.authenticated
        @isAuthenticated = response.authenticated
        @userData = response.userData
        if @location.url() == @_getOption('loginPage')
          @location.url @redirectUrl
        if callback then callback()
      else
        @signOut(callback)
    ).error((response) =>
      console.log 'Failed to check Authentication:', response
    )

  _onSignedIn: ->
    @isAuthenticated = true
    @location.url @redirectUrl
    @rootScope.$broadcast('bzzUserSignedIn')

  setSignIn: (provider, accessToken) ->
    path = '/auth/signin/'
    @http.post(@_getOption('bzzApiUrl') + path,
      provider: provider
      access_token: accessToken
    )

  signIn: (provider, authResult, callback) ->
    @setSignIn(provider, authResult.access_token).then((response) =>
      if response.data.authenticated
        @_onSignedIn()
        if callback then callback()
      else
        @signOut(callback)
    , =>
      @signOut(callback)
    )

  _onSignedOut: ->
    @isAuthenticated = false
    @userData = null
    @location.url @_getOption('loginPage')
    @rootScope.$broadcast('bzzUserSignedOut')

  setSignOut: ->
    path = '/auth/signout/'
    @http.post(@_getOption('bzzApiUrl') + path, '')

  signOut: (callback) ->
    @setSignOut().success((response) =>
      if response.loggedOut
        @_onSignedOut()
        if callback then callback()
    ).error((response) =>
      console.log 'Failed to signOut: ', response
    )

  googleLogin: (callback) =>
    @GooglePlus.login().then((authResult) =>
      @signIn('google', authResult, callback)
    , (err) =>
      @signOut(callback)
    )

angular.module('bzz.auth', ['ngRoute', 'googleplus'])
  .provider('AuthService', (GooglePlusProvider) ->
    @init = (customOptions) ->
      @options = angular.extend(options, customOptions)
      @initializeGooglePlus(@options)  # if google enabled

    @initializeGooglePlus = (options) ->
      GooglePlusProvider.init
        clientId: options['googleClientId']
        apiKey: options['googleApiKey']
        scopes: options['googleScopes']

    @$get = ($http, $rootScope, $location, $route, GooglePlus) ->
      new AuthService(@options, $http, $rootScope, $location, $route, GooglePlus)

    return
  )
