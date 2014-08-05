'use strict'

describe 'Directive: authButton', ->

  # load the directive's module
  #beforeEach module 'bzzAngularApp'

  beforeEach module 'bzz.auth'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<auth-button provider="google"></auth-button>'
    element = $compile(element) scope
    scope.$digest()
    expect(element.text()).toBe '\nEntrar com google'
