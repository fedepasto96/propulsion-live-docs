#
# sync-html.ps1 — Syncs all HTML files from the E4 Battery Planning shared drive
# to the local git repo and pushes changes to GitHub for GitHub Pages deployment.
#
# Usage:
#   .\sync-html.ps1              # Sync all HTML files
#   .\sync-html.ps1 -DryRun      # Show what would change without committing
#

param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot
$SrcDir = "H:\Shared drives\ENG - Elios 3, payloads and accessories program\Harmony Project\03_Technical\03_08_Batteries\E4 Battery Project\01_Project Management\01_03_Planning"

$Folders = @(
    "Charger Suppliers",
    "Cost Evaluation Material",
    "Pack Assemblers",
    "project updates",
    "Regulatory",
    "Reports",
    "Supplier Engagement"
)

Set-Location $RepoDir

$Changed = 0

if ($DryRun) {
    Write-Host "[DRY RUN] Showing changes without committing." -ForegroundColor Yellow
}

foreach ($folder in $Folders) {
    $srcFolder = Join-Path $SrcDir $folder
    $dstFolder = Join-Path $RepoDir $folder

    if (-not (Test-Path $dstFolder)) {
        New-Item -ItemType Directory -Path $dstFolder -Force | Out-Null
    }

    $htmlFiles = Get-ChildItem -Path $srcFolder -Filter "*.html" -ErrorAction SilentlyContinue

    foreach ($file in $htmlFiles) {
        $dstFile = Join-Path $dstFolder $file.Name

        $needsCopy = $false
        if (-not (Test-Path $dstFile)) {
            $needsCopy = $true
        } else {
            $srcHash = (Get-FileHash $file.FullName -Algorithm MD5).Hash
            $dstHash = (Get-FileHash $dstFile -Algorithm MD5).Hash
            if ($srcHash -ne $dstHash) {
                $needsCopy = $true
            }
        }

        if ($needsCopy) {
            $Changed++
            if ($DryRun) {
                Write-Host "  [CHANGED] $folder\$($file.Name)" -ForegroundColor Cyan
            } else {
                Copy-Item $file.FullName -Destination $dstFile -Force
                Write-Host "  Updated: $folder\$($file.Name)" -ForegroundColor Green
            }
        }
    }
}

# Scan for HTML files in new subfolders
$allHtml = Get-ChildItem -Path $SrcDir -Filter "*.html" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notlike "*\.cursor\*" }

foreach ($file in $allHtml) {
    $relPath = $file.FullName.Substring($SrcDir.Length + 1)
    $dstFile = Join-Path $RepoDir $relPath

    if (-not (Test-Path $dstFile)) {
        $Changed++
        $dstDir = Split-Path $dstFile -Parent
        if ($DryRun) {
            Write-Host "  [NEW] $relPath" -ForegroundColor Magenta
        } else {
            if (-not (Test-Path $dstDir)) {
                New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
            }
            Copy-Item $file.FullName -Destination $dstFile -Force
            Write-Host "  New file: $relPath" -ForegroundColor Green
        }
    }
}

if ($Changed -eq 0) {
    Write-Host "`nNo changes detected. Everything is up to date." -ForegroundColor Gray
    exit 0
}

if ($DryRun) {
    Write-Host "`n$Changed file(s) would be updated." -ForegroundColor Yellow
    exit 0
}

Write-Host "`n$Changed file(s) updated. Committing and pushing..." -ForegroundColor White

git add -A
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Sync HTML documents - $timestamp`n`nAuto-sync of $Changed modified file(s) from shared drive."
git push origin main

Write-Host "`nDone. Changes pushed to GitHub. GitHub Pages will update shortly." -ForegroundColor Green
Write-Host "View at: https://fedepasto-96.github.io/e4-battery-planning-docs/" -ForegroundColor Cyan
