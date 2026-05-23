param(
    [string]$kfver = "v6.25.0",
    [string]$plasmaver = "v6.5.91"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

. "$PSScriptRoot\buildutils.ps1"

#region Initialize build Env and VSDev Shell
. Initialize-BuildEnvironment
if ($IsWindows) {
    Initialize-VSDevShell -DevCmdArguments "-arch=x64 -host_arch=x64"
}
#endregion

#region Check pre-requirements
# Required by ki18n on Windows
Check-ExecutableExists -ExecutableName "xgettext"
Check-ExecutableExists -ExecutableName "python"
#endregion

#region Build

# Required by ki18n on Windows
Build-CMakeProject `
    -RepoUrl "https://github.com/BLumia/libintl.git" `
    -Version "master" `
    -RepoName "libintl" `
    -InstallPrefix "kf6redist-install"

Build-KF6Module -KfVer $kfver -RepoName "extra-cmake-modules"
Build-KF6Module -KfVer $kfver -RepoName "kcoreaddons" -CMakeArgs "-DBUILD_TESTING=OFF"
Build-KF6Module -KfVer $kfver -RepoName "kconfig" -CMakeArgs "-DBUILD_TESTING=OFF"
Build-KF6Module -KfVer $kfver -RepoName "kguiaddons" -CMakeArgs "-DBUILD_TESTING=OFF"
Build-KF6Module -KfVer $kfver -RepoName "ki18n" -CMakeArgs "-DBUILD_TESTING=OFF"
Build-KF6Module -KfVer $kfver -RepoName "kwidgetsaddons" -CMakeArgs "-DBUILD_TESTING=OFF"
Build-KF6Module -KfVer $kfver -RepoName "kcolorscheme" -CMakeArgs "-DBUILD_TESTING=OFF"

# Required by kiconthemes
Build-CMakeProject `
    -RepoUrl "https://github.com/madler/zlib.git" `
    -Version "v1.3.1.2" `
    -RepoName "zlib" `
    -InstallPrefix "kf6redist-install"

Build-KF6Module -KfVer $kfver -RepoName "karchive" `
    -CMakeArgs "-DBUILD_TESTING=OFF", "-DWITH_LIBZSTD=OFF", "-DWITH_BZIP2=OFF", "-DWITH_LIBLZMA=OFF"
Build-KF6Module -KfVer $kfver -RepoName "kiconthemes" `
    -CMakeArgs "-DBUILD_TESTING=OFF", "-DUSE_BreezeIcons=OFF", "-DKICONTHEMES_USE_QTQUICK=OFF"
Build-KF6Module -KfVer $kfver -RepoName "kwindowsystem" -CMakeArgs "-DBUILD_TESTING=OFF"

Build-CMakeProject `
    -RepoUrl "https://invent.kde.org/plasma/breeze.git" `
    -Version $plasmaver `
    -RepoName "breeze" `
    -InstallPrefix "kf6redist-install" `
    -PatchFiles "./patches/breeze-option-no-quick-n-cursor.diff" `
    -CMakeArgs "-DBUILD_TESTING=OFF", "-DBUILD_QT5=OFF", "-DWITH_DECORATIONS=OFF", "-DBUILD_WITH_QTQUICK=OFF", "-DBUILD_CURSOR=OFF"
#endregion
