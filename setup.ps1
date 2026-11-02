# Downloads the providers and modules each root module needs, so that
# `provlift check` can see the shared module's ceiling. The lock files are
# already committed at old versions; this script does not change them.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

# Share provider downloads between roots; the AWS provider alone is large.
if (-not $env:TF_PLUGIN_CACHE_DIR) {
    $env:TF_PLUGIN_CACHE_DIR = Join-Path $HOME '.terraform.d/plugin-cache'
}
New-Item -ItemType Directory -Force $env:TF_PLUGIN_CACHE_DIR | Out-Null

# envs/kubernetes is skipped on purpose so `provlift drift` reports its
# missing lock file.
foreach ($root in 'envs/aws-prod', 'envs/aws-stage', 'envs/azure', 'envs/gcp', 'envs/github') {
    Write-Host "terraform init $root"
    terraform "-chdir=$root" init -backend=false -input=false -no-color | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "terraform init failed in $root" }
}

if (Get-Command tofu -ErrorAction SilentlyContinue) {
    Write-Host 'tofu init opentofu/platform'
    tofu '-chdir=opentofu/platform' init -backend=false -input=false -no-color | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'tofu init failed in opentofu/platform' }
} else {
    Write-Warning 'tofu is not on PATH; skipping the OpenTofu stack.'
}

Write-Host 'Ready. Reset between runs with: git checkout . ; git clean -fd'
