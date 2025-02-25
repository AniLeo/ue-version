#!/bin/bash

# Attempt extracting the version from exif data
analyse_ue_exifdata()
{
  # Find the provided file anywhere inside the game directory
  file_path=$(find "${1/#\~/$HOME}" -type f -name "$2" 2>/dev/null)

  # Failed to find the file
  if [ -z "$file_path" ]; then
    echo "File '$2' not found"
    return 1
  fi

  # Get the "File Version Number" exif property
  exif_output=$(exiftool -FileVersionNumber "$file_path" 2>/dev/null)

  # Failed to get the property
  if [[ "$exif_output" != *"File Version Number"* ]]; then
    echo "Failed to extract the File Version Number exif property"
    return 1
  fi

  # Extract the version from the result
  version=$(echo "$exif_output" | awk -F ': ' '{print $2}')

  # Failed to find X.Y.W.Z semver version
  if [[ !$version =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Failed to extract the UE version $version"
    return 1
  fi

  # Invalid version extracted, game developer likely replaced the version
  if [[ $version =~ ^1\. ]]; then
    echo "Invalid version extracted: $version"
    return 1
  fi

  echo "$version"
  return 0
}

# Attempt extracting the UE build stamp from the Shipping executable
analyse_ue_buildstamp()
{
  # Find the provided file anywhere inside the game directory
  file_path=$(find "${1/#\~/$HOME}" -type f -name "*-Shipping.exe" 2>/dev/null)

  # Failed to find the file
  if [ -z "$file_path" ]; then
    echo "File '*-Shipping.exe' not found"
    return 1
  fi

  # Get the "File Version Number" exif property
  strings_output=$(strings "$file_path" | grep -oP "UE[0-9]+\+Release-" | head -n 1 2>/dev/null)

  # Failed to find any build stamp strings in the executable
  if [ -z "$strings_output" ]; then
    echo "Could not find any buildstamp strings"
    return 1
  fi

  # Extract the version number
  version=$(echo "$strings_output" | grep -oP '\+Release-\K[0-9]+\.[0-9]+' 2>/dev/null)

  # Failed to extract the version from the build stamp string
  if [ -z "$version" ]; then
    echo "Could not extract the version from the buildstamp string"
    return 1
  fi

  echo "$version"
  return 0
}

# Attempt extracting the UE build version from the Build properties
analyse_ue_buildversion()
{
  # Find the build version properties file anywhere inside the game directory
  file_path=$(find "${1/#\~/$HOME}" -type f -name "Build.version" 2>/dev/null)

  # Failed to find the file
  if [ -z "$file_path" ]; then
    echo "File 'Build.version' not found"
    return 1
  fi

  # Read the properties file, extract and format the version
  major=$(grep -oP '"MajorVersion": \K[0-9]+' "$file_path")
  minor=$(grep -oP '"MinorVersion": \K[0-9]+' "$file_path")
  patch=$(grep -oP '"PatchVersion": \K[0-9]+' "$file_path")
  changelist=$(grep -oP '"Changelist": \K[0-9]+' "$file_path")

  if [[ -z "$major" || -z "$minor" || -z "$patch" || -z "$changelist" ]]; then
    echo "One or more version components could not be extracted"
    return 1
  fi

  version="$major.$minor.$patch.$changelist"

  echo "$version"
  return 0
}
