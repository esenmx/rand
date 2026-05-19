.PHONY: test analyze format dry publish coverage

test:
	dart test

analyze:
	dart analyze --fatal-infos --fatal-warnings

format:
	dart format .

coverage:
	dart pub global activate coverage
	dart test --coverage=coverage
	dart pub global run coverage:format_coverage \
		--lcov --in=coverage --out=coverage/lcov.info --report-on=lib

dry:
	dart pub publish --dry-run

publish:
	dart pub publish
