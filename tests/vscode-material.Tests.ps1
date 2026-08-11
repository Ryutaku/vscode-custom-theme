$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripts\vscode-material.ps1'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('vscode-custom-theme-test-' + [guid]::NewGuid().ToString('N'))
$fixturePath = Join-Path $testRoot 'main.js'
$original = 'let Qe=createOptions();Ve("code/willCreateCodeBrowserWindow"),this._win=new wr.BrowserWindow(Qe),Ve("code/didCreateCodeBrowserWindow");class Theme{updateBackgroundColor(e,t){for(let r of Ui())if(r.id===e){r.setBackgroundColor(t.colorInfo.background);break}}}'

try {
    New-Item -ItemType Directory -Path $testRoot | Out-Null
    [System.IO.File]::WriteAllText($fixturePath, $original, (New-Object System.Text.UTF8Encoding($false)))

    & $scriptPath acrylic -MainJsPath $fixturePath | Out-Null
    $acrylic = [System.IO.File]::ReadAllText($fixturePath)
    if (
        $acrylic -notmatch 'background-material=acrylic' -or
        $acrylic -notmatch 'Qe\.backgroundMaterial="acrylic"' -or
        $acrylic -notmatch 'Qe\.transparent=!0' -or
        $acrylic -notmatch 'delete Qe\.backgroundColor' -or
        $acrylic -notmatch 'preserve-background-material=acrylic' -or
        $acrylic -notmatch 'r\.setBackgroundMaterial\?\.\("acrylic"\)' -or
        $acrylic -match 'r\.setBackgroundColor\(t\.colorInfo\.background\);break'
    ) {
        throw 'Acrylic patch was not applied as expected.'
    }

    & $scriptPath mica -MainJsPath $fixturePath | Out-Null
    $mica = [System.IO.File]::ReadAllText($fixturePath)
    if ($mica -notmatch 'background-material=mica' -or $mica -match 'background-material=acrylic') {
        throw 'Switching from Acrylic to Mica did not replace the existing patch.'
    }

    $status = (& $scriptPath status -MainJsPath $fixturePath) -join "`n"
    if ($status -notmatch 'Background material: mica') {
        throw 'Status did not report the active Mica mode.'
    }

    & $scriptPath disable -MainJsPath $fixturePath | Out-Null
    $disabled = [System.IO.File]::ReadAllText($fixturePath)
    if ($disabled -ne $original) {
        throw 'Disabling the patch did not restore the original fixture exactly.'
    }

    Write-Output 'PASS: acrylic, mica, status, and disable operations are reversible.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
