setup:
	@bundle
	@npm install .
	@bower install

unit:
	@grunt test

run:
	@grunt serve

release:
	@grunt build
	@-cp dist/scripts/bzz.angular.*.js bzz.angular.min.js
	@-cp dist/styles/bzz.angular.*.css bzz.angular.min.css
