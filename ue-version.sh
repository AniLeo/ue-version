#!/bin/bash
source ./ue-version-heuristics.sh

# Check if the path argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
  echo "ExifTool is not installed on your system."
  echo ""
  echo "Please install it before using ue-version."
  echo "  - Arch: sudo pacman -S perl-image-exiftool"
  echo "  - Debian/Ubuntu: sudo apt install libimage-exiftool-perl"
  echo "  - Fedora: sudo dnf install perl-Image-ExifTool"
  exit 1
fi

# Note: The calling order of the heuristics matters, most to least reliable
declare -a error_messages

version=$(analyse_ue_buildversion "$1")
if [ $? -eq 0 ]; then
  echo "$version"
  exit 0
else
  error_messages+=("$version")
fi

for exe in "CrashReportClient.exe" "EpicWebHelper.exe"; do
  version=$(analyse_ue_exifdata "$1" "$exe")
  if [ $? -eq 0 ]; then
    echo "$version"
    exit 0
  else
    error_messages+=("$version")
  fi
done

version=$(analyse_ue_buildstamp "$1")
if [ $? -eq 0 ]; then
  echo "$version"
  exit 0
else
  error_messages+=("$version")
fi

version=$(analyse_ue_exifdata "$1" "*-Shipping.exe")
if [ $? -eq 0 ]; then
  echo "$version"
  exit 0
else
  error_messages+=("$version")
fi

echo "All the known heuristics to extract the version failed"
echo "Error messages: "
for error_message in "${error_messages[@]}"; do
  echo "$error_message"
done
exit 1
