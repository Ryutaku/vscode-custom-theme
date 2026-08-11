[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('status', 'acrylic', 'mica', 'tabbed', 'auto', 'disable')]
    [string]$Mode = 'status',

    [string]$CodeCommand = 'code',

    [string]$MainJsPath
)

$ErrorActionPreference = 'Stop'

$patchPattern = '/\* vscode-custom-theme:background-material=(?<mode>acrylic|mica|tabbed|auto) \*/(?<options>[A-Za-z_$][\w$]*)\.backgroundMaterial="(?<value>acrylic|mica|tabbed|auto)",(?:\k<options>\.transparent=!0,)?(?:delete \k<options>\.backgroundColor,)?'
$runtimePatchPattern = '/\* vscode-custom-theme:preserve-background-material=(?<mode>acrylic|mica|tabbed|auto) \*/[A-Za-z_$][\w$]*\.setBackgroundMaterial\?\.\("(?:acrylic|mica|tabbed|auto)"\)/\* vscode-custom-theme:original-background-call=(?<original>[^*]+) \*/'
$windowPattern = '(?<prefix>[A-Za-z_$][\w$]*\("code/willCreateCodeBrowserWindow"\),)(?<assignment>this\._win=new [A-Za-z_$][\w$]*\.BrowserWindow\((?<options>[A-Za-z_$][\w$]*)\))'
$runtimeWindowPattern = '(?<call>(?<window>[A-Za-z_$][\w$]*)\.setBackgroundColor\((?<splash>[A-Za-z_$][\w$]*)\.colorInfo\.background\))'

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
$existingRuntimePatches = [regex]::Matches($source, $runtimePatchPattern)

if ($existingPatches.Count -gt 1 -or $existingRuntimePatches.Count -gt 1) {
    throw "Found duplicate vscode-custom-theme material patches in $targetPath. Refusing to make an ambiguous change."
}

$currentMode = if (
    $existingPatches.Count -eq 1 -and
    $existingRuntimePatches.Count -eq 1 -and
    $existingPatches[0].Groups['mode'].Value -eq $existingRuntimePatches[0].Groups['mode'].Value
) {
    $existingPatches[0].Groups['mode'].Value
}
elseif ($existingPatches.Count -eq 1 -or $existingRuntimePatches.Count -eq 1) {
    'partial (run an enable mode again to repair)'
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
    if ($existingPatches.Count -eq 0 -and $existingRuntimePatches.Count -eq 0) {
        Write-Output "Background material is already disabled."
        exit 0
    }

    $updated = $source
    if ($existingRuntimePatches.Count -eq 1) {
        $runtimePatchRegex = New-Object System.Text.RegularExpressions.Regex($runtimePatchPattern)
        $updated = $runtimePatchRegex.Replace(
            $updated,
            [System.Text.RegularExpressions.MatchEvaluator]{
                param($match)
                $match.Groups['original'].Value
            },
            1
        )
    }
    if ($existingPatches.Count -eq 1) {
        $updated = [regex]::Replace($updated, $patchPattern, '', 1)
    }
    Write-Utf8NoBomAtomic -Path $targetPath -Content $updated
    Write-Output "Disabled the VS Code background material patch. Restart every VS Code window to apply the change."
    exit 0
}

if ($existingRuntimePatches.Count -eq 1) {
    $runtimePatchRegex = New-Object System.Text.RegularExpressions.Regex($runtimePatchPattern)
    $source = $runtimePatchRegex.Replace(
        $source,
        [System.Text.RegularExpressions.MatchEvaluator]{
            param($match)
            $match.Groups['original'].Value
        },
        1
    )
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
$injection = "/* vscode-custom-theme:background-material=$Mode */$optionsName.backgroundMaterial=`"$Mode`",$optionsName.transparent=!0,delete $optionsName.backgroundColor,"
$replacement = $match.Groups['prefix'].Value + $injection + $match.Groups['assignment'].Value
$updated = $source.Substring(0, $match.Index) + $replacement + $source.Substring($match.Index + $match.Length)

$runtimeWindowMatches = [regex]::Matches($updated, $runtimeWindowPattern)
if ($runtimeWindowMatches.Count -ne 1) {
    throw "Expected one VS Code runtime background-color update, found $($runtimeWindowMatches.Count). This VS Code build is not supported yet."
}

$runtimeMatch = $runtimeWindowMatches[0]
$runtimeWindowName = $runtimeMatch.Groups['window'].Value
$originalRuntimeCall = $runtimeMatch.Groups['call'].Value
$runtimeInjection = "/* vscode-custom-theme:preserve-background-material=$Mode */$runtimeWindowName.setBackgroundMaterial?.(`"$Mode`")/* vscode-custom-theme:original-background-call=$originalRuntimeCall */"
$updated = $updated.Substring(0, $runtimeMatch.Index) + $runtimeInjection + $updated.Substring($runtimeMatch.Index + $runtimeMatch.Length)

$backupPath = "$targetPath.vscode-custom-theme.original"
if (-not (Test-Path -LiteralPath $backupPath)) {
    Copy-Item -LiteralPath $targetPath -Destination $backupPath
}

Write-Utf8NoBomAtomic -Path $targetPath -Content $updated

$writtenSource = [System.IO.File]::ReadAllText($targetPath)
$writtenPatches = [regex]::Matches($writtenSource, $patchPattern)
$writtenRuntimePatches = [regex]::Matches($writtenSource, $runtimePatchPattern)
if (
    $writtenPatches.Count -ne 1 -or
    $writtenRuntimePatches.Count -ne 1 -or
    $writtenPatches[0].Groups['mode'].Value -ne $Mode -or
    $writtenRuntimePatches[0].Groups['mode'].Value -ne $Mode
) {
    Copy-Item -LiteralPath $backupPath -Destination $targetPath -Force
    throw 'Patch verification failed. The original main.js was restored.'
}

Write-Output "Enabled VS Code background material: $Mode"
Write-Output "Patched file: $targetPath"
Write-Output "Safety backup: $backupPath"
Write-Output 'Restart every VS Code window to apply the change.'
