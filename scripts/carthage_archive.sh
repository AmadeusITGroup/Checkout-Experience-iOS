#!/bin/bash

# Script to install dependancies and make a Carthage archive of the SDK


function PatchDependencies {
    # There is a bug in CardIO preventing it to be compiled in Xcode 13.
    # The `ARCHS` variable has to be removed: 
    sed -i.bak  "s/ARCHS = .*//" ./Carthage/Checkouts/card.io-iOS-source/build_configs/CardIO_Framework.xcconfig 
}

cd "$(dirname "$0")"
cd ..

./scripts/carthage.sh update --no-build || exit 1

PatchDependencies

./scripts/carthage.sh build --archive || exit 1

