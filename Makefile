EXAMPLES_WORKSPACE = Examples/ComposableCoreLocationExamples.xcworkspace
XCODEBUILD_FLAGS = -configuration Debug
IOS_SIMULATOR_DESTINATION = generic/platform=iOS Simulator
MACOS_DESTINATION = platform=macOS

default: test

test: test-package test-examples

test-package:
	swift test

generate-examples:
	cd Examples && tuist install
	cd Examples && tuist generate --no-open

build-example-ios: generate-examples
	xcodebuild build \
		-workspace "$(EXAMPLES_WORKSPACE)" \
		-scheme LocationManagerMobile \
		$(XCODEBUILD_FLAGS) \
		-destination '$(IOS_SIMULATOR_DESTINATION)'

build-example-macos: generate-examples
	xcodebuild build \
		-workspace "$(EXAMPLES_WORKSPACE)" \
		-scheme LocationManagerDesktop \
		$(XCODEBUILD_FLAGS) \
		-destination '$(MACOS_DESTINATION)'

test-example-feature: generate-examples
	xcodebuild test \
		-workspace "$(EXAMPLES_WORKSPACE)" \
		-scheme LocationManagerFeature \
		$(XCODEBUILD_FLAGS) \
		-destination '$(MACOS_DESTINATION)'

test-examples: build-example-ios build-example-macos test-example-feature

format:
	swift format --in-place --recursive \
		./Examples ./Package.swift ./Sources ./Tests

.PHONY: \
	build-example-ios \
	build-example-macos \
	default \
	format \
	generate-examples \
	test \
	test-example-feature \
	test-examples \
	test-package
