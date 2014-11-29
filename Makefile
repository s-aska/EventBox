
default: test

build:
	xcodebuild -sdk iphonesimulator -target EventBox build

test:
	#xcodebuild -sdk iphonesimulator -scheme EventBoxTests test
	xctool -sdk iphonesimulator -arch i386 -scheme EventBoxTests test

clean:
	xcodebuild -sdk iphonesimulator clean

.PHONY: build test clean default