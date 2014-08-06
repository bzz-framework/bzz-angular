'use strict'

describe 'Service: AuthServiceProvider', ->

  authServiceProvider = {}

  # load the service's module
  beforeEach ->
    angular.module('testApp', ->).config (AuthServiceProvider) ->
      authServiceProvider = AuthServiceProvider

    module('bzz.auth', 'testApp')
    inject(->)

  it 'should not be null', ->
    expect(authServiceProvider).not.toBeUndefined()

  it 'should configure all options', ->
    authServiceProvider.init
      googleClientId: 'client-id'
      googleApiKey: 'api-key'
      googleScopes: 'scopes'
      bzzApiUrl: 'bzz-url'
      redirectWhenLogin: '/home'
      loginPage: '/login-page'
    expect(authServiceProvider.options['googleClientId']).toEqual 'client-id'
    expect(authServiceProvider.options['googleApiKey']).toEqual 'api-key'
    expect(authServiceProvider.options['googleScopes']).toEqual 'scopes'
    expect(authServiceProvider.options['bzzApiUrl']).toEqual 'bzz-url'
    expect(authServiceProvider.options['redirectWhenLogin']).toEqual '/home'
    expect(authServiceProvider.options['loginPage']).toEqual '/login-page'

describe 'Service: AuthService', ->

  async = new AsyncSpec @

  # load the service's module
  async.beforeEach (done) ->
    module 'bzz.auth'
    done()

  # instantiate service
  authService = {}
  httpBackend = {}
  location = {}
  bzzApiUrl = 'http://test.com:2368/api'
  async.beforeEach (done) ->
    inject (AuthService, $httpBackend, $location) ->
      authService = AuthService
      authService.options =
        bzzApiUrl: bzzApiUrl
        redirectWhenLogin: '/'
        loginPage: '/login'
      httpBackend = $httpBackend
      location = $location
      done()
      return

  async.it 'should check authentication when authenticated and get user data', (done) ->
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: true
      userData:
        id: 123
        email: 'test@test.com'
        name: 'test 123'
        provider: 'provider'
    authService.checkAuthentication(->
      expect(authService.isAuthenticated).toEqual true
      expect(authService.userData).toEqual
        id: 123
        email: 'test@test.com'
        name: 'test 123'
        provider: 'provider'
      done()
    )
    httpBackend.flush()

  async.it 'should check authentication when not authenticated then signOut', (done) ->
    # make sure that isAuthenticated and userData attributes is undefined
    delete authService.isAuthenticated
    delete authService.userData
    # mock POST /auth/signout
    httpBackend.whenPOST(bzzApiUrl + '/auth/signout/').respond
      loggedOut: true
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: false
    authService.checkAuthentication(->
      expect(authService.isAuthenticated).toEqual false
      expect(authService.userData).toEqual null
      done()
    )
    httpBackend.flush()

  async.it 'should bind event of unauthorizedRequest', (done) ->
    # make sure that isAuthenticated and userData attributes is undefined
    delete authService.isAuthenticated
    delete authService.userData
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: true
    # mock POST /auth/signout
    httpBackend.whenPOST(bzzApiUrl + '/auth/signout/').respond
      loggedOut: true
    authService.rootScope.$broadcast('unauthorizedRequest', ->
      expect(authService.isAuthenticated).toEqual false
      expect(authService.userData).toEqual null
      done()
    )
    httpBackend.flush()

  async.it 'should bind event of locationChangeStart', (done) ->
    # make sure that isAuthenticated and userData attributes is undefined
    delete authService.isAuthenticated
    delete authService.userData
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: true
      userData:
        id: 123
        email: 'test@test.com'
        name: 'test 123'
        provider: 'provider'
    authService.rootScope.$broadcast('$locationChangeStart', null, null, ->
      expect(authService.isAuthenticated).toEqual true
      expect(authService.userData).toEqual
        id: 123
        email: 'test@test.com'
        name: 'test 123'
        provider: 'provider'
      done()
    )
    httpBackend.flush()

  async.it 'should authenticate on googleplus', (done) ->
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: true
    # mock POST /auth/signin
    httpBackend.whenPOST(bzzApiUrl + '/auth/signin/').respond
      authenticated: true
    googlePlus =
      login: ->
        then: (callback) ->
          callback(
            access_token: '1234567890'
          )
    authService.GooglePlus = googlePlus

    authService.googleLogin(->
      expect(authService.isAuthenticated).toBe true
      expect(location.url()).toBe '/home'
      done()
    )
    httpBackend.flush()

  async.it 'shouldnt authenticate on googleplus with invalid access_token', (done) ->
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: false
    # mock POST /auth/signin
    httpBackend.whenPOST(bzzApiUrl + '/auth/signin/').respond(401, 'Unauthorized')
    # mock POST /auth/signout
    httpBackend.whenPOST(bzzApiUrl + '/auth/signout/').respond
      loggedOut: true
    googlePlus =
      login: ->
        then: (callback) ->
          callback(
            access_token: '1234567890'
          )

    authService.GooglePlus = googlePlus
    authService.googleLogin(->
      expect(authService.isAuthenticated).toBe false
      expect(location.path()).toBe '/login'
      done()
    )
    httpBackend.flush()

  async.it 'should return to previous entered page after login', (done) ->
    authService.rootScope.$broadcast('$locationChangeStart', 'http://server/login', 'http://server/other-page', ->
      done()
    )
    expect(authService.redirectUrl).toBe('/other-page')
    done()

  async.it 'should not return to previous entered page after login with the previous is login', (done) ->
    authService.rootScope.$broadcast('$locationChangeStart', 'http://server/login', 'http://server/login', ->
      done()
    )
    expect(authService.redirectUrl).toBe('/home')
    done()

  async.it 'should redirect to previous entered page if authenticated in login page', (done) ->
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: true
    location.url('/login')
    authService.rootScope.$broadcast('$locationChangeStart', 'http://server/login', 'http://server/other-page', ->
      expect(location.url()).toBe('/other-page')
      done()
    )
    httpBackend.flush()
