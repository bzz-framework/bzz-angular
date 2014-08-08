bzz-angular
===========

bzz-angular offers extensions to angular.js to interoperate with bzz.

Resources
=========

 * AuthService provider: allows easy integration with bzz authentication api
 * AuthButton directive: allows easy login button implementation with default UI

Supported providers
-------------------

 * GooglePlus
 * Facebook (still not implemented)
 * Github (still not implemented)
 * OAuth 2 (still not implemented)

Installing with bower
=====================

    bower install --save bzz-angular

Configuring AuthService
=======================

First, add `'bzz.auth'` on your module application's dependencies array:

```javascript
var myModule = angular.module('myWebApp', [
  // ...
  'bzz.auth'
])
```

Then add `AuthServiceProvider` and angular `$httpProvider` as dependencies on the config step of your app:

```javascript
myModule.config(function($routeProvider, /* ... */, $httpProvider, AuthServiceProvider) {
  // AuthServiceProvider configuration explained below...
})
```

On the routes you need authentication check, you need to to configure these routes with `requiresAuthentication` flag:

```
  $routeProvider.when('/needs-authentication', {
    controller: function() {},
    requiresAuthentication: true
  });
```

In the example above, the route `/needs-authentication` is configured with authentication check. This means that every time this route is changed to the current, a event to check authentication will be broadcasted to `AuthService`.

Still in the the config step, you need to configure the initialization vars for the service (the values below are the default ones). bzz-angular comes with sensible defaults, but you must configure the Client ID and Secret for the providers you want to use (in this example, Google). You must also configure the URL where bzz can be found:

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
  // This allows bzz-angular to make sure the user is authenticated in routes that require authentication.
  $httpProvider.responseInterceptors.push('httpResponseInterceptor')
```

Using the authentication service is as easy as using angular's dependency injection with:

```javascript
myModule.run(function (AuthService) {});
```

The resulting code will looks like this:

```javascript
angular.module('myWebApp', [
  // ...
  'bzz.auth'
]).config(function($routeProvider, /* ... */, $httpProvider, AuthServiceProvider) {
  $routeProvider.when('/needs-authentication', {
    controller: function() {},
    requiresAuthentication: true
  });
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

bzz-angular comes with an `auth-button` directive. The goal is to make it simple to include authentication in your application. Just use in your templates:

```html
  <auth-button provider="google"></auth-button>
```
