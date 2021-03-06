REPORTER = dot

build:
	@./node_modules/.bin/coffee -b -o lib src/*.coffee

test: build
	@NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script \
		--reporter $(REPORTER)

coverage: build
	@jscoverage --no-highlight lib lib-cov
	@DOJO_COV=1 $(MAKE) test REPORTER=html-cov > doc/coverage.html
	@rm -rf lib-cov

.PHONY: test
