'use strict'

describe 'Service: httpInterceptor', ->

  # load the service's module
  beforeEach module 'bzzAngularApp'

  # instantiate service
  httpInterceptor = {}
  beforeEach inject (_httpInterceptor_) ->
    httpInterceptor = _httpInterceptor_

  it 'should do something', ->
    expect(!!httpInterceptor).toBe true
