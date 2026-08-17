$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$clientExe = Join-Path $projectRoot '.tools\mysql\mysql-8.0.43-winx64\bin\mysqladmin.exe'
$databasePassword = $env:DB_PASSWORD
if (-not $databasePassword) {
  $databasePassword = [Environment]::GetEnvironmentVariable('DB_PASSWORD', 'User')
}
if (-not $databasePassword) {
  throw 'DB_PASSWORD is not set in the process or current Windows user environment.'
}

$env:MYSQL_PWD = $databasePassword
try {
  & $clientExe '--protocol=tcp' '--host=127.0.0.1' '--port=3306' '--user=root' shutdown
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
  Write-Host 'MySQL stopped.'
} finally {
  Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
}
