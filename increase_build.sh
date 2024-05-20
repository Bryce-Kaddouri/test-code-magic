#!/bin/bash

path_to_pubspec="pubspec.yaml"
current_version=$(awk '/^version:/ {print $2}' $path_to_pubspec)
current_version_without_build=$(echo "$current_version" | sed 's/\+.*//')
revisionoffset=0
build_number=$(echo "$current_version" | sed 's/.*+//')
echo "Current build number: $build_number"
new_build_number=$((build_number + 1))
echo "New build number: $new_build_number"
new_version="$current_version_without_build+$new_build_number"
echo "Setting pubspec.yaml version $current_version to $new_version"
sed -i "" "s/version: $current_version/version: $new_version/g" $path_to_pubspec