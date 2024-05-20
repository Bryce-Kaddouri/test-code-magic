          #!/bin/bash


android_manifest="android/app/build.gradle"
version_code=$(grep -o "versionCode [0-9]*" $android_manifest | cut -d ' ' -f 2)
new_version_code=$((version_code + 1))
sed -i '' "s/versionCode $version_code/versionCode $new_version_code/" $android_manifest

# Increase iOS build number
ios_info_plist="ios/Runner/Info.plist"
build_number=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $ios_info_plist)
new_build_number=$((build_number + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_build_number" $ios_info_plist

echo "Android version code incremented to $new_version_code"
echo "iOS build number incremented to $new_build_number"