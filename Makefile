SCHEME = BubbleUp

.PHONY: build test lint autocorrect swiftformat swiftlint_autocorrect bootstrap

ci: build
ac: autocorrect
autocorrect: swiftformat swiftlint_autocorrect clangformat

lint:
	swiftlint --strict

swiftformat:
	git ls-files '*.h' '*.m' -z | xargs -0 swiftformat --commas inline

swiftlint_autocorrect:
	swiftlint autocorrect

clangformat:
	git ls-files '*.h' '*.m' -z | xargs -0 clang-format -i

build:
	xcodebuild build \
		-alltargets \
		-configuration Debug

bootstrap:
	carthage bootstrap

test:
	xcodebuild test \
		-alltargets \
		-configuration Debug \
		-scheme $(SCHEME)

