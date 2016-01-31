.PHONY: all test clean build

all: build test

clean:
	swift build --clean

build:
	swift build

test:
	.build/debug/spectre-build
