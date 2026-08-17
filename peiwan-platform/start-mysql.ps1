$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$mysqlRoot = Join-Path $projectRoot '.tools\mysql'
$serverExe = Join-Path $mysqlRoot 'mysql-8.0.43-winx64\bin\mysqld.exe'
$configFile = Join-Path $mysqlRoot 'my.ini'

if (-not (Test-Path -LiteralPath $serverExe)) {
  throw "MySQL Server executable not found: $serverExe"
}

$listener = Get-NetTCPConnection -LocalPort 3306 -State Listen -ErrorAction SilentlyContinue
if ($listener) {
  Write-Host 'MySQL port 3306 is already listening.'
  exit 0
}

$process = Start-Process -FilePath $serverExe -ArgumentList "--defaults-file=$configFile" -WindowStyle Hidden -PassThru
for ($attempt = 0; $attempt -lt 30; $attempt++) {
  try {
    $connection = [System.Net.Sockets.TcpClient]::new()
    $connection.Connect('127.0.0.1', 3306)
    $connection.Dispose()
    Write-Host "MySQL 8.0.43 started on 127.0.0.1:3306 (PID $($process.Id))."
    exit 0
  } catch {
    Start-Sleep -Milliseconds 500
  }
}

throw 'MySQL did not start on port 3306. Check .tools/mysql/mysql-error.log.'
