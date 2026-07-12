$repoDir = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$versionFile = "$repoDir\VERSION"
$flutterPubspec = "$repoDir\src\flutter_app\pubspec.yaml"
$pyproject = "$repoDir\pyproject.toml"

if (-not (Test-Path $versionFile)) {
    Write-Host "Error: VERSION file not found at $versionFile" -ForegroundColor Red
    exit 1
}

$version = (Get-Content $versionFile -Raw).Trim()
if (-not $version) {
    Write-Host "Error: VERSION file is empty" -ForegroundColor Red
    exit 1
}

# Derive build number from git commit count
$buildNumber = 1
try {
    $buildNumber = git -C $repoDir rev-list --count HEAD
} catch {
    $buildNumber = 1
}

# Update Flutter pubspec.yaml
if (Test-Path $flutterPubspec) {
    $content = Get-Content $flutterPubspec -Raw
    $content = $content -replace '^version:.*', "version: $version+$buildNumber"
    Set-Content $flutterPubspec -Value $content -NoNewline
    Write-Host "Flutter: $flutterPubspec -> $version+$buildNumber"
}

# Update pyproject.toml
if (Test-Path $pyproject) {
    $content = Get-Content $pyproject -Raw
    $content = $content -replace '^version = ".*"', "version = `"$version`""
    Set-Content $pyproject -Value $content -NoNewline
    Write-Host "Python: $pyproject -> $version"
}
