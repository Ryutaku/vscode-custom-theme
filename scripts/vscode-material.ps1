[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('status', 'acrylic', 'mica', 'tabbed', 'auto', 'disable')]
    [string]$Mode = 'status',

    [string]$CodeCommand = 'code',

    [string]$MainJsPath
)

$ErrorActionPreference = 'Stop'

$patchPattern = '/\* vscode-custom-theme:background-material=(?<mode>acrylic|mica|tabbed|auto) \*/(?<options>[A-Za-z_$][\w$]*)\.backgroundMaterial="(?<value>acrylic|mica|tabbed|auto)",(?:delete \k<options>\.backgroundColor,)?'
$windowPattern = '(?<prefix>[A-Za-z_$][\w$]*\("code/willCreateCodeBrowserWindow"\),)(?<assignment>this\._win=new [A-Za-z_$][\w$]*\.BrowserWindow\((?<options>[A-Za-z_$][\w$]*)\))'

function Resolve-MainJsPath {
    if ($MainJsPath) {
        return [System.IO.Path]::GetFullPath($MainJsPath)
    }

    $command = Get-Command $CodeCommand -ErrorAction Stop
    $commandPath = $command.Source
    if (-not $commandPath) {
        $commandPath = $command.Path
    }

    if (-not $commandPath) {
        throw "Could not resolve the '$CodeCommand' command. Pass -MainJsPath explicitly."
    }

    if ([System.IO.Path]::GetExtension($commandPath) -ieq '.cmd') {
        $launcher = [System.IO.File]::ReadAllText($commandPath)
        $versionMatch = [regex]::Match(
            $launcher,
            '%~dp0\.\.\\(?<version>[^\\"\r\n]+)\\resources\\app\\out\\cli\.js',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )

        if ($versionMatch.Success) {
            $installRoot = Split-Path (Split-Path $commandPath -Parent) -Parent
            return Join-Path $installRoot "$($versionMatch.Groups['version'].Value)\resources\app\out\main.js"
        }
    }

    $installRoot = Split-Path (Split-Path $commandPath -Parent) -Parent
    $candidates = @(Get-ChildItem -LiteralPath $installRoot -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Join-Path $_.FullName 'resources\app\out\main.js' } |
        Where-Object { Test-Path -LiteralPath $_ })

    if ($candidates.Count -eq 1) {
        return $candidates[0]
    }

    throw "Could not identify the active VS Code main.js. Pass -MainJsPath explicitly."
}

function Write-Utf8NoBomAtomic {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Content
    )

    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    $directory = Split-Path $resolvedPath -Parent
    $temporaryPath = Join-Path $directory ('.vscode-custom-theme-' + [guid]::NewGuid().ToString('N') + '.tmp')
    $replacementBackupPath = "$temporaryPath.replaced"
    $encoding = New-Object System.Text.UTF8Encoding($false)

    try {
        [System.IO.File]::WriteAllText($temporaryPath, $Content, $encoding)
        [System.IO.File]::Replace($temporaryPath, $resolvedPath, $replacementBackupPath)
    }
    finally {
        if (Test-Path -LiteralPath $temporaryPath) {
            Remove-Item -LiteralPath $temporaryPath -Force
        }
        if (Test-Path -LiteralPath $replacementBackupPath) {
            Remove-Item -LiteralPath $replacementBackupPath -Force
        }
    }
}

$targetPath = Resolve-MainJsPath
if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
    throw "VS Code main process file was not found: $targetPath"
}

$targetPath = (Resolve-Path -LiteralPath $targetPath).Path
$source = [System.IO.File]::ReadAllText($targetPath)
$existingPatches = [regex]::Matches($source, $patchPattern)

if ($existingPatches.Count -gt 1) {
    throw "Found more than one vscode-custom-theme material patch in $targetPath. Refusing to make an ambiguous change."
}

$currentMode = if ($existingPatches.Count -eq 1) {
    $existingPatches[0].Groups['mode'].Value
}
else {
    'disabled'
}

if ($Mode -eq 'status') {
    Write-Output "VS Code main.js: $targetPath"
    Write-Output "Background material: $currentMode"
    exit 0
}

if ($Mode -eq 'disable') {
    if ($existingPatches.Count -eq 0) {
        Write-Output "Background material is already disabled."
        exit 0
    }

    $updated = [regex]::Replace($source, $patchPattern, '', 1)
    Write-Utf8NoBomAtomic -Path $targetPath -Content $updated
    Write-Output "Disabled the VS Code background material patch. Restart every VS Code window to apply the change."
    exit 0
}

if ($existingPatches.Count -eq 1) {
    $source = [regex]::Replace($source, $patchPattern, '', 1)
}

$windowMatches = [regex]::Matches($source, $windowPattern)
if ($windowMatches.Count -ne 1) {
    throw "Expected one VS Code BrowserWindow creation site, found $($windowMatches.Count). This VS Code build is not supported yet."
}

$match = $windowMatches[0]
$optionsName = $match.Groups['options'].Value
$injection = "/* vscode-custom-theme:background-material=$Mode */$optionsName.backgroundMaterial=`"$Mode`",delete $optionsName.backgroundColor,"
$replacement = $match.Groups['prefix'].Value + $injection + $match.Groups['assignment'].Value
$updated = $source.Substring(0, $match.Index) + $replacement + $source.Substring($match.Index + $match.Length)

$backupPath = "$targetPath.vscode-custom-theme.original"
if (-not (Test-Path -LiteralPath $backupPath)) {
    Copy-Item -LiteralPath $targetPath -Destination $backupPath
}

Write-Utf8NoBomAtomic -Path $targetPath -Content $updated

$writtenSource = [System.IO.File]::ReadAllText($targetPath)
$writtenPatches = [regex]::Matches($writtenSource, $patchPattern)
if ($writtenPatches.Count -ne 1 -or $writtenPatches[0].Groups['mode'].Value -ne $Mode) {
    Copy-Item -LiteralPath $backupPath -Destination $targetPath -Force
    throw 'Patch verification failed. The original main.js was restored.'
}

Write-Output "Enabled VS Code background material: $Mode"
Write-Output "Patched file: $targetPath"
Write-Output "Safety backup: $backupPath"
Write-Output 'Restart every VS Code window to apply the change.'
