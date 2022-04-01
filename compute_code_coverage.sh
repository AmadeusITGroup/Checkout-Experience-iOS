#!/bin/bash

function print {
	echo -e "\x1B[95m$1\x1B[0m"
}

if [[ "$1" == "" ]]; then
	print "Usage: ./compute_code_coverage.sh <device-id>"
	print
	print "Available devices are:"
	xcrun xctrace list devices
else
	rm -rf coverage-report.xcresult
	xcodebuild -resultBundlePath coverage-report.xcresult -workspace AmadeusCheckout.xcworkspace -scheme AmadeusCheckout -sdk iphonesimulator -destination "id=$1" test
	xcrun xccov view --report --only-targets coverage-report.xcresult
fi
