'use strict'

describe 'Service: AuthService', ->

  # load the service's module
  beforeEach module 'bzzAngularApp'

  # instantiate service
  authService = {}
  beforeEach inject (_AuthService_) ->
    authService = _AuthService_

  it 'should do something', ->
    expect(!!authService).toBe true
