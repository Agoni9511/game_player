$backendRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $backendRoot
$env:JAVA_HOME = Join-Path $projectRoot ".tools\jdk\jdk-21.0.12+8"
$maven = Join-Path $projectRoot ".tools\maven\apache-maven-3.9.16\bin\mvn.cmd"

$env:ADMIN_INITIAL_PASSWORD = '123456'

& $maven spring-boot:run
