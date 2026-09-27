<#
.SYNOPSIS
    Build the iOS app on GitHub Actions and download the .ipa to .\dist

.DESCRIPTION
    Commits local changes, pushes, waits for the workflow to finish,
    then downloads the unsigned .ipa artifact.

.EXAMPLE
    .\build.ps1
    .\build.ps1 -m "add login screen"
#>
param(
    [string]$m = "Update app sources"
)

$ErrorActionPreference = "Stop"
$gh = "C:\Program Files\GitHub CLI\gh.exe"
if (-not (Test-Path $gh)) { $gh = (Get-Command gh -ErrorAction Stop).Source }

Push-Location $PSScriptRoot
try {
    Write-Host "==> Committing changes" -ForegroundColor Cyan
    git add -A
    if (git diff --cached --quiet) {
        Write-Host "    nothing to commit, using existing HEAD"
    }
    else {
        git commit -m $m
    }

    Write-Host "==> Pushing to main (triggers the workflow)" -ForegroundColor Cyan
    git push origin main

    $sha    = git rev-parse HEAD
    Write-Host "==> Waiting for the run on $sha" -ForegroundColor Cyan

    $runId = $null
    for ($i = 0; $i -lt 30 -and -not $runId; $i++) {
        Start-Sleep -Seconds 3
        $runId = & $gh run list --commit $sha --limit 1 --json databaseId --jq '.[0].databaseId' 2>$null
    }
    if (-not $runId) { throw "No workflow run appeared for $sha. Check the Actions tab." }

    Write-Host "==> Watching run $runId" -ForegroundColor Cyan
    & $gh run watch $runId --exit-status --interval 10 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Build failed. See: gh run view $runId --log-failed" }

    Write-Host "==> Downloading artifact" -ForegroundColor Cyan
    Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue
    & $gh run download $runId --name MyApp-unsigned-ipa --dir dist

    $ipa = Get-ChildItem dist -Filter *.ipa | Select-Object -First 1
    Write-Host "`nOK  $($ipa.FullName)  ($([math]::Round($ipa.Length/1KB,1)) KB)" -ForegroundColor Green
}
finally {
    Pop-Location
}
