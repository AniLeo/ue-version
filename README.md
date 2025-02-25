# ue-version
A tool that analyses Unreal Engine 4 and Unreal Engine 5 based games and determines what version of the engine was used to build the game.

## Usage
`./ue-version.sh <directory>`

### Requirements
- [exiftool](https://exiftool.org/)
  - Arch: `sudo pacman -S perl-image-exiftool`
  - Debian/Ubuntu: `sudo apt install libimage-exiftool-perl`
  - Fedora: `sudo dnf install perl-Image-ExifTool`

### Examples
```
./ue-version.sh "~/.local/share/Steam/steamapps/common/Jusant"
5.1.1.0
```
```
./ue-version.sh "~/.local/share/Steam/steamapps/common/Stray"
4.27.2.0
```

## Heuristics
This tool uses different heuristics to determine the engine version, listed here from most to least reliable
- **analyse_ue_buildversion:** Analyses "Build.version", found in UE4 games;
- **analyse_ue_exifdata (tools):** Analyses exif data for Unreal Engine tools such as "CrashReportClient.exe" and "EpicWebHelper.exe", found in UE5 and UE4 games;
- **analyse_ue_buildstamp:** Analyses build stamp strings inside game executables, found in UE4 games;
- **analyse_ue_exifdata (game):** Analyses exif data for the Shipping executable, found in UE5 and UE4 games.

## License
This project is licensed under the GNU GPLv2 license. This software may be modified/distributed for commercial or private use but changes to the source code must be published under the same license, containing a copy of the license and a copyright notice.

Developed by [AniLeo](https://github.com/AniLeo) at ani-leo@outlook.com (C) 2025.
