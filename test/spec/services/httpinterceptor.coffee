'use strict'

describe 'Service: httpInterceptor', ->

  # load the service's module
  beforeEach module 'bzz.auth'

  # instantiate service
  httpInterceptor = {}
  beforeEach inject (httpResponseInterceptor) ->
    httpInterceptor = httpResponseInterceptor

  it 'should do something', ->
    expect(!!httpInterceptor).toBe true
