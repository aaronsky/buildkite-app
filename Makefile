# Facts
GIT_REPO_TOPLEVEL := $(shell git rev-parse --show-toplevel)

# Apple platform destinations
DESTINATION_PLATFORM_IOS_SIMULATOR = platform=iOS Simulator,name=iPhone 14 Pro Max
DESTINATION_PLATFORM_MACOS = platform=macOS

# Formatting
SWIFT_FORMAT_BIN := swift format
SWIFT_FORMAT_CONFIG_FILE := $(GIT_REPO_TOPLEVEL)/.swift-format.json
FORMAT_PATHS := $(GIT_REPO_TOPLEVEL)/App $(GIT_REPO_TOPLEVEL)/Package.swift $(GIT_REPO_TOPLEVEL)/Sources $(GIT_REPO_TOPLEVEL)/Tests

# Tasks

.PHONY: test test-iOS test-macOS
test: test-iOS test-macOS
test-iOS:
	@xcodebuild test \
		-project App/Buildkite.xcodeproj \
		-scheme Buildkite \
		-destination "$(DESTINATION_PLATFORM_IOS_SIMULATOR)" \
		-quiet
test-macOS:
	@xcodebuild test \
		-project App/Buildkite.xcodeproj \
		-scheme Buildkite \
		-destination "$(DESTINATION_PLATFORM_MACOS)" \
		-quiet

.PHONY: format
format:
	$(SWIFT_FORMAT_BIN) \
		--configuration $(SWIFT_FORMAT_CONFIG_FILE) \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		$(FORMAT_PATHS)

.PHONY: lint
lint:
	$(SWIFT_FORMAT_BIN) lint \
		--configuration $(SWIFT_FORMAT_CONFIG_FILE) \
		--ignore-unparsable-files \
		--recursive \
		$(FORMAT_PATHS)
