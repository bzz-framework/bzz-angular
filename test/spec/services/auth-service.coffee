'use strict'

describe 'Service: AuthService', ->

  async = new AsyncSpec @

  # load the service's module
  async.beforeEach (done) ->
    module 'bzzAngularApp'
    done()

  # instantiate service
  authService = {}
  httpBackend = {}
  location = {}
  async.beforeEach (done) ->
    inject (_AuthService_, $httpBackend, $location) ->
      authService = _AuthService_
      httpBackend = $httpBackend
      location = $location
      done()
      return

  # TODO: make bzz url configurable
  bzzApiUrl = 'http://local.bzz.com:9000'

  it 'should have default values for flag vars', ->
    expect(authService.bzzApiUrl).toEqual bzzApiUrl

  async.it 'should check authentication when authenticated', (done) ->
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: true
      userData:
        id: 123
        email: 'test@test.com'
        name: 'test 123'
        provider: 'provider'
    authService.checkAuthentication(->
      expect(authService.isLoggedIn).toEqual true
      expect(authService.userData).toEqual
        id: 123
        email: 'test@test.com'
        name: 'test 123'
        provider: 'provider'
      done()
    )
    httpBackend.flush()

  async.it 'should check authentication when not authenticated then logout', (done) ->
    # make sure that isLoggedIn and userData attributes is undefined
    delete authService.isLoggedIn
    delete authService.userData
    # mock POST /auth/signout
    httpBackend.whenPOST(bzzApiUrl + '/auth/signout/').respond
      loggedOut: true
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: false
    authService.checkAuthentication(->
      expect(authService.isLoggedIn).toEqual false
      expect(authService.userData).toEqual null
      done()
    )
    httpBackend.flush()

  async.it 'should bind event of unauthorizedRequest', (done) ->
    # make sure that isLoggedIn and userData attributes is undefined
    delete authService.isLoggedIn
    delete authService.userData
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: true
    # mock POST /auth/signout
    httpBackend.whenPOST(bzzApiUrl + '/auth/signout/').respond
      loggedOut: true
    authService.rootScope.$broadcast('unauthorizedRequest', ->
      expect(authService.isLoggedIn).toEqual false
      expect(authService.userData).toEqual null
      done()
    )
    httpBackend.flush()

  async.it 'should bind event of locationChangeStart', (done) ->
    # make sure that isLoggedIn and userData attributes is undefined
    delete authService.isLoggedIn
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
      expect(authService.isLoggedIn).toEqual true
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
      authenticated: false
    # mock POST /auth/signin
    httpBackend.whenPOST(bzzApiUrl + '/auth/signin/').respond
      authenticated: true
    googlePlus =
      login: ->
        then: (callback) ->
          callback(
            access_token: '1234567890'
          )

    authService.googlePlus = googlePlus
    authService.googleLogin(->
      expect(authService.isLoggedIn).toBe true
      expect(location.path()).toBe '/'
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

    authService.googlePlus = googlePlus
    authService.googleLogin(->
      expect(authService.isLoggedIn).toBe false
      expect(location.path()).toBe '/login'
      done()
    )
    httpBackend.flush()
