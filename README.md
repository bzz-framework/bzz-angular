bzz-angular
===========

bzz-angular offers extensions to angular.js to interoperate with bzz.

Resources
=========

 * AuthService provider: allows easy integration with bzz authentication api
 * AuthButton directive: allows easy login button implementation with nice default CSS

Supported providers
-------------------

 * GooglePlus

Installing with bower
=====================

    bower install --save bzz-angular

Configuring the service
=======================

Add `'bzz.auth'` on your module application`s dependencies array, I.E:

```javascript
var myModule = angular.module('myWebApp', [
  // ...
  'bzz.auth'
])
```

Then add `AuthServiceProvider` and angular `$httpProvider` as a dependency injection on the config function:

```javascript
myModule.config(function($routeProvider, /* ... */, $httpProvider, AuthServiceProvider) {
  // $routeProvider ...
  // code explained below here...
})
```

In the the config function, configure the initialization vars for the service (the values belowe is the defaults ones, excepting googleClientId and googleApiKey that the defaults is `null`):

```javascript
  AuthServiceProvider.init({
    googleClientId: 'MYGOOGLECLIENTID'
    googleApiKey: 'MYGOOGLEAPIKEY'
    googleScopes: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
    bzzApiUrl: 'http://localhost:2368/'
    redirectWhenLogin: '/'
    loginPage: '/login'
  });
```

And add `httpResponseInterceptor` to the `$httpProvider.responseInterceptors` array:

```javascript
  $httpProvider.responseInterceptors.push('httpResponseInterceptor')
```

Now, for run the Service at the initialization of your angular application, inject the AuthService on the `run` method of your module (nothing need to be done after it):

```javascript
myModule.run(function (AuthService) {});
```

The resulting code will looks like this:

```javascript
angular.module('myWebApp', [
  // ...
  'bzz.auth'
]).config(function($routeProvider, /* ... */, $httpProvider, AuthServiceProvider) {
  // $routeProvider ...
  // configuring
  AuthServiceProvider.init({
    googleClientId: 'MYGOOGLECLIENTID'
    googleApiKey: 'MYGOOGLEAPIKEY'
    googleScopes: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
    bzzApiUrl: 'http://localhost:2368/'
    redirectWhenLogin: '/'
    loginPage: '/login'
  });
  $httpProvider.responseInterceptors.push('httpResponseInterceptor');
}).run(function (AuthService) {});
```

AuthButton Directive
====================

To simple & fast login method, use the AuthButton directive. It has a really nice default CSS and is easy-as-click to make you authenticated. Just use in your templates:

```html
  <auth-button provider="google"></auth-button>
```
