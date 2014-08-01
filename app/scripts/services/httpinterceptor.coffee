'use strict'

###*
 # @ngdoc service
 # @name bzzAngularApp.httpInterceptor
 # @description
 # # httpInterceptor
 # Factory in the bzzAngularApp.
###
angular.module('bzz.auth')
  .factory("httpResponseInterceptor", ($q, $rootScope) ->

    onError = (response) ->
      if response.status is 401
        $rootScope.$broadcast('unauthorizedRequest')
      $q.reject response

    onSuccess = (response) ->
      return response

    promise = (promise) ->
      promise.then(onSuccess, onError)

  )
