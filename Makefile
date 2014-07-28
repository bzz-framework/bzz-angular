setup:
	@bundle
	@npm install .
	@bower install

unit:
	@grunt test

run:
	@grunt serve
