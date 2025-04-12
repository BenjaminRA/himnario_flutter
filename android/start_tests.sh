#!/bin/bash

kill_emulators() {
  adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
}

wait_emulator_to_be_ready() {
  kill_emulators
  emulator -avd "$1" -no-audio -no-boot-anim -no-window -accel on -gpu off & boot_completed=false
  while [ "$boot_completed" = false ]
   do
    status=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
    echo "Boot Status: $status"

    if [ "$status" = "1" ];
      then
        boot_completed=true
      else
        sleep 1
    fi
  done
}

disable_animation() {
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
}

# clean previous builds
flutter clean

# init emulators
wait_emulator_to_be_ready $1

# run tests
SCREENSHOT_PATH=$2 PLATFORM=$3 flutter drive --driver=test_driver/screenshot_integration_test_driver.dart --target=integration_test/screenshot_test.dart

# kill emulators
kill_emulators