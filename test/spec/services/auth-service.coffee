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
  async.beforeEach (done) ->
    inject (_AuthService_, $httpBackend) ->
      authService = _AuthService_
      httpBackend = $httpBackend
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
    # mock POST /auth/signout
    httpBackend.whenPOST(bzzApiUrl + '/auth/signout/').respond
      loggedOut: true
    authService.rootScope.$broadcast('unauthorizedRequest', done)
    httpBackend.flush()

  async.it 'should bind event of locationChangeStart', (done) ->
    # mock GET /auth/me
    httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      authenticated: true
    authService.rootScope.$broadcast('$locationChangeStart', null, null, done)
    httpBackend.flush()

  #it 'should verify users authentication information when logged in', ->
    #httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      #authenticated: true
      #userData:
        #id: 123
        #email: 'test@test.com'
        #name: 'test 123'
        #provider: 'provider'
    #authService.getAuthMe().then((response) ->
      #expect(response.status).toEqual 200
      #expect(response.data.authenticated).toEqual true
      #expect(response.data.userData).toEqual
        #id: 123
        #email: 'test@test.com'
        #name: 'test 123'
        #provider: 'provider'
    #)
    #httpBackend.flush()

  #it 'should verify users authentication information when logged out', ->
    #httpBackend.whenGET(bzzApiUrl + '/auth/me/').respond
      #authenticated: false
    #authService.getAuthMe().then((response) ->
      #expect(response.status).toEqual 200
      #expect(response.data.authenticated).toEqual false
    #)
    #httpBackend.flush()
