'use strict'

describe 'Directive: authButton', ->

  # load the directive's module
  beforeEach module 'bzzAngularApp'

  scope = {}

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()

  it 'should make hidden element visible', inject ($compile) ->
    element = angular.element '<auth-button></auth-button>'
    element = $compile(element) scope
    expect(element.text()).toBe 'Entrar com {{ model.provider }}'
