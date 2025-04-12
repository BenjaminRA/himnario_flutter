#!/bin/sh

# # by default, the execution directory of this script is the ci_scripts directory
# # CI_WORKSPACE is the directory of your cloned repo
# echo "🟩 Navigate from ($PWD) to ($CI_WORKSPACE)" 
# cd $CI_WORKSPACE
# export PATH="$PATH:$HOME/flutter/bin"
# export GEM_HOME=~/.gem
# export PATH="$GEM_HOME/bin:$PATH"

# echo "🟩 Delete old screenshots"
# rm -r $CI_WORKSPACE/ios/fastlane/screenshots/es-MX/**

# echo "🟩 Delete all devices"
# xcrun simctl delete all
# export SIMULATOR_RUNTIME=$(xcrun simctl list runtimes | grep -o 'com\.apple\..*')

# # echo "🟩 Create iPhone 8 Simulator (4.7-inch)"
# # xcrun simctl create iphone_8 com.apple.CoreSimulator.SimDeviceType.iPhone-8 $SIMULATOR_RUNTIME

# # echo "🟩 Running test on iPhone 8 Simulator (4.7-inch)"
# # xcrun simctl boot iphone_8
# # time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=iPhone_8 flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# # xcrun simctl shutdown iphone_8

# echo "🟩 Create iPhone 8 Plus Simulator (5.5-inch)"
# xcrun simctl create iphone_8_plus com.apple.CoreSimulator.SimDeviceType.iPhone-8-Plus $SIMULATOR_RUNTIME

# echo "🟩 Running tests on iPhone 8 Plus Simulator (5.5-inch)"
# xcrun simctl boot iphone_8_plus
# time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=iphone_8_plus flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# xcrun simctl shutdown iphone_8_plus

# # echo "🟩 Create iPhone 14 Simulator (5.8-inch)"
# # xcrun simctl create iphone_14 com.apple.CoreSimulator.SimDeviceType.iPhone-14 $SIMULATOR_RUNTIME

# # echo "🟩 Running tests on iPhone 14 Simulator (5.8-inch)"
# # xcrun simctl boot iphone_14
# # time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=iphone_14 flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# # xcrun simctl shutdown iphone_14

# # echo "🟩 Create iPhone 14 Pro Simulator (6.1-inch)"
# # xcrun simctl create iphone_14_pro com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro $SIMULATOR_RUNTIME

# # echo "🟩 Running tests on iPhone 14 Pro Simulator (6.1-inch)"
# # xcrun simctl boot iphone_14_pro
# # time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=iphone_14_pro flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# # xcrun simctl shutdown iphone_14_pro

# echo "🟩 Create iPhone 14 Plus Simulator (6.5-inch)"
# xcrun simctl create iphone_14_plus com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus $SIMULATOR_RUNTIME

# echo "🟩 Running tests on iPhone 14 Plus Simulator (6.5-inch)"
# xcrun simctl boot iphone_14_plus
# time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=iphone_14_plus flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# xcrun simctl shutdown iphone_14_plus

# echo "🟩 Create iPhone 14 Pro Max Simulator (6.7-inch)"
# xcrun simctl create iphone_14_pro_max com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro-Max $SIMULATOR_RUNTIME

# echo "🟩 Running tests on iPhone 14 Pro Max Simulator (6.7-inch)"
# xcrun simctl boot iphone_14_pro_max
# time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=iphone_14_pro_max flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# xcrun simctl shutdown iphone_14_pro_max

# # echo "🟩 Create iPad (6th generation) Simulator (9.7-inch)"
# # xcrun simctl create ipad_6gen com.apple.CoreSimulator.SimDeviceType.iPad--6th-generation- $SIMULATOR_RUNTIME

# # echo "🟩 Running tests on iPad (6th generation) Simulator (9.7-inch)"
# # xcrun simctl boot ipad_6gen
# # time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=ipad_6gen flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# # xcrun simctl shutdown ipad_6gen

# # echo "🟩 Create iPad (9th generation) Simulator (10.5-inch)"
# # xcrun simctl create ipad_9gen com.apple.CoreSimulator.SimDeviceType.iPad-9th-generation $SIMULATOR_RUNTIME

# # echo "🟩 Running tests on iPad (9th generation) Simulator (10.5-inch)"
# # xcrun simctl boot ipad_9gen
# # time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=ipad_9gen flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# # xcrun simctl shutdown ipad_9gen

# # echo "🟩 Create iPad (10th generation) Simulator (11-inch)"
# # xcrun simctl create ipad_10gen com.apple.CoreSimulator.SimDeviceType.iPad-10th-generation $SIMULATOR_RUNTIME

# # echo "🟩 Running tests on iPad (10th generation) Simulator (11-inch)"
# # xcrun simctl boot ipad_10gen
# # time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=ipad_10gen flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# # xcrun simctl shutdown ipad_10gen

# echo "🟩 Create iPad Pro (2th generation) Simulator (12.9-inch)"
# xcrun simctl create ipad_pro_2gen com.apple.CoreSimulator.SimDeviceType.iPad-Pro--12-9-inch---2nd-generation- $SIMULATOR_RUNTIME

# echo "🟩 Running tests on iPad Pro (2th generation) Simulator (12.9-inch)"
# xcrun simctl boot ipad_pro_2gen
# time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=ipad_pro_2gen flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# xcrun simctl shutdown ipad_pro_2gen

# echo "🟩 Create iPad Pro (6th generation) Simulator (12.9-inch)"
# xcrun simctl create ipad_pro_6gen com.apple.CoreSimulator.SimDeviceType.iPad-Pro-12-9-inch-6th-generation-8GB $SIMULATOR_RUNTIME

# echo "🟩 Running tests on iPad Pro (6th generation) Simulator (12.9-inch)"
# xcrun simctl boot ipad_pro_6gen
# time SCREENSHOT_PATH=$CI_WORKSPACE/ios/fastlane/screenshots/es-MX PLATFORM=ios DEVICE_NAME=IPAD_PRO_3GEN_129 flutter drive --driver=$CI_WORKSPACE/test_driver/screenshot_integration_test_driver.dart --target=$CI_WORKSPACE/integration_test/screenshot_test.dart
# xcrun simctl shutdown ipad_pro_6gen

# echo "🟩 Uploading metadata to the App Store"
# time cd ios && bundle exec fastlane deliver_metadata

exit 0