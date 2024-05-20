#!/bin/bash

# Required tools: curl, convert (ImageMagick)
# This script downloads an image from a specified URL using curl and resizes it for Android and iOS app icons and launch images, with enhanced quality settings.

set -o pipefail

download_image() {
    local url=$1
    local output_path=$2

    if ! curl -s -o "$output_path" "$url"; then
        printf "Failed to download image from %s\n" "$url" >&2
        return 1
    fi
}

resize_image() {
    local input_path=$1
    local output_path=$2
    local size=$3

    # Enhance image quality during resizing
    if ! convert "$input_path" -resize "${size}x${size}" \
                               -unsharp 1.5x1.0+1.5+0.02 \
                               -quality 100 \
                               "$output_path"; then
        printf "Failed to resize image to %s with enhanced quality\n" "$size" >&2
        return 1
    fi
}

prepare_android_icons() {
    local input_image=$1
    local base_path="android/app/src/main/res"

    local -A size_map=(
        [48]="mdpi"
        [72]="hdpi"
        [96]="xhdpi"
        [144]="xxhdpi"
        [192]="xxxhdpi"
    )

    for size in "${!size_map[@]}"; do
        local density="${size_map[$size]}"
        local directory="${base_path}/mipmap-${density}"
        mkdir -p "$directory"
        if ! resize_image "$input_image" "${directory}/ic_launcher.png" "$size"; then
            printf "Error creating Android icon for density %s.\n" "$density" >&2
            return 1
        fi
    done
}

prepare_ios_app_icons() {
    local input_image=$1
    local base_path="ios/Runner/Assets.xcassets/AppIcon.appiconset"
    mkdir -p "$base_path"

    local ios_sizes_app_icon=(20 29 40 50 57 58 60 72 76 80 87 100 114 120 144 152 167 180 1024)
    for size in "${ios_sizes_app_icon[@]}"; do
        if ! resize_image "$input_image" "${base_path}/${size}.png" "$size"; then
            printf "Error creating iOS app icon for size %s.\n" "$size" >&2
            return 1
        fi
    done
}

prepare_asset_app_icons() {
    # write image in assets/images/logo.png with 1200x1200 size
    local input_image=$1
    local base_path="assets/image"
    mkdir -p "$base_path"

    if ! resize_image "$input_image" "${base_path}/logo.png" "1200"; then
        printf "Error creating asset app icon for size 1200.\n" >&2
        return 1
    fi


}

prepare_ios_launch_images() {
    local input_image=$1
    local base_path="ios/Runner/Assets.xcassets/LaunchImage.imageset"
    mkdir -p "$base_path"

    local ios_sizes_launch_image=(300 600 900)
    for size in "${ios_sizes_launch_image[@]}"; do
        local suffix=""
        if [[ "$size" == 600 ]]; then
            suffix="@2x"
        elif [[ "$size" == 900 ]]; then
            suffix="@3x"
        fi

        if ! resize_image "$input_image" "${base_path}/LaunchImage${suffix}.png" "$size"; then
            printf "Error creating iOS launch image for size %s.\n" "$size" >&2
            return 1
        fi
    done
}

main() {
    local url=$1

    if [[ -z "$url" ]]; then
        printf "Usage: %s <url>\n" "$(basename "$0")" >&2
        return 1
    fi

    local original_image="downloaded_image.png"
    if ! download_image "$url" "$original_image"; then
        printf "Error downloading the image.\n" >&2
        return 1
    fi

    prepare_android_icons "$original_image"
    prepare_ios_app_icons "$original_image"
    prepare_ios_launch_images "$original_image"
    prepare_asset_app_icons "$original_image"

    rm "$original_image"
}

main "$@"
