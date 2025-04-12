#!/bin/sh

# by default, the execution directory of this script is the ci_scripts directory
# CI_WORKSPACE is the directory of your cloned repo 
echo "🟩 Navigate from ($PWD) to ($CI_WORKSPACE)"
cd $CI_WORKSPACE

echo "🟩 Install Flutter"
time git clone https://github.com/flutter/flutter.git -b 1.22.6 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

echo "🟩 Flutter Precache"
time flutter precache --ios

echo "🟩 Install Flutter Dependencies"
time flutter pub get
sed -i '' 's/registrar {/registrar {\n\t\[\[IntegrationTestPlugin instance\] setupChannels:registrar.messenger\];/g' $HOME/flutter/packages/integration_test/ios/Classes/IntegrationTestPlugin.m

echo "🟩 Install CocoaPods via Homebrew"
time HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

echo "🟩 Install CocoaPods dependencies"
time cd ios && pod install

echo "🟩 Build in release mode"
time flutter build ios --release

# echo "🟩 Install fastlane"
# export GEM_HOME=~/.gem
# export PATH="$GEM_HOME/bin:$PATH"
# time gem install bundle
# time bundle install

# echo "🟩 Install Simulator runtime"
# time xcodebuild -downloadAllPlatforms

exit 0