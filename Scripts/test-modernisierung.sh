#!/bin/bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Aufruf: Scripts/test-modernisierung.sh <Simulator-UDID>" >&2
    echo "Simulatoren anzeigen: xcrun simctl list devices available" >&2
    exit 2
fi

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
if [ -z "${DEVELOPER_DIR:-}" ] && [ -d /Applications/Xcode.app/Contents/Developer ]; then
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
derived_dir="${AXTIMES_TEST_DERIVED_DATA:-${TMPDIR:-/tmp}/axtimes-modernisierung-tests}"
xcodebuild -workspace "$project_dir/aXTimes.xcworkspace" -scheme aXTimes \
    -configuration Debug -destination "platform=iOS Simulator,id=$1" \
    -derivedDataPath "$derived_dir" -only-testing:'Unit Tests/UnitTest' test
