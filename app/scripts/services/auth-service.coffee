'use strict'

# class AuthService
#   constructor: (@rootScope) ->
#     @getAuthenticationFlags()
#     @bindEvents()
# 
#   bindEvents: ->
#     @rootScope.$on('unauthorizedRequest', (event) =>
#       @logout()
#     )
#     @rootScope.$on('$locationChangeStart', (e, n, p) =>
#       @getAuthenticationFlags()
#     )
# 
#   getAuthentication: ->
#     @restangular.one('authenticate').get()
# 
#   removeAuthentication: ->
#     @restangular.one('authenticate').remove()
# 
#   authenticate: (data) ->
#     @restangular.all('authenticate').post(data)
# 
#   getAuthenticationFlags: ->
#     @getAuthentication().then((response) =>
#       @rootScope.isLoggedIn = response.authenticated
#       @rootScope.isSuperUser = response.isSuperUser
#       @logoutIfNotAuthenticated()
#     )
# 
#   logoutIfNotAuthenticated: ->
#     if @rootScope.isLoggedIn is false
#       @logout()
# 
#   redirectIfAuthenticated: ->
#     if @rootScope.isLoggedIn is true
#       @location.url '/'
# 
#   redirectIfNotSuperUser: (path) ->
#     if @rootScope.isSuperUser is false
#       @location.url path
# 
#   logout: ->
#     @removeAuthentication().then((result) =>
#       if result.loggedOut
#         @rootScope.isLoggedIn = false
#         @location.url "/login"
#     )
# 
#   googleLogin: ->
#     @googlePlus.login().then((authResult) =>
#       data = {
#         access_token: authResult.access_token,
#         provider: 'GooglePlus'
#       }
#       @authenticate(data).then((response) =>
#         if response.authenticated
#           @rootScope.isLoggedIn = true
# 
#           @UserViolationsPrefsFcty.getInitialUserViolationsPrefs().then((data) =>
#             @localStorage.userprefs = _.groupBy(data, 'category')
#           )
# 
#           if response.first_login
#             @location.url "/user/violations/prefs/"
#           else
#             @location.url "/"
#         else
#           @logout()
#       , ->
#         @logout()
#       )
#     , (err) ->
#       @logout()
#     )

class AuthService

  constructor: (@http, @rootScope) ->
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
    path = '/auth/signout/'
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
          callback()
      ).error((response) =>
        console.log 'Failed to Logout: ', response
      )
    else
      callback()

  checkAuthentication: (callback) ->
    @getAuthMe().success((response) =>
      if response.authenticated
        @isLoggedIn = response.authenticated
        @userData = response.userData
        callback()
      else
        @logout(callback)
    ).error((response) =>
      console.log 'Failed to check Authentication:', response
    )

angular.module('bzzAngularApp')
  .service('AuthService', ($http, $rootScope) ->
    new AuthService($http, $rootScope)
  )
