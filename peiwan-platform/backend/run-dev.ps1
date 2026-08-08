$backendRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $backendRoot
$env:JAVA_HOME = Join-Path $projectRoot ".tools\jdk\jdk-21.0.12+8"
$maven = Join-Path $projectRoot ".tools\maven\apache-maven-3.9.16\bin\mvn.cmd"

if (-not $env:ADMIN_INITIAL_PASSWORD) {
  $securePassword = Read-Host "首次启动管理员 admin 密码" -AsSecureString
  $env:ADMIN_INITIAL_PASSWORD = [System.Net.NetworkCredential]::new('', $securePassword).Password
}

& $maven spring-boot:run
