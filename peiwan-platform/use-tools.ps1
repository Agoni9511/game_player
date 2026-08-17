$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$env:JAVA_HOME = Join-Path $projectRoot ".tools\jdk\jdk-21.0.12+8"
$env:MAVEN_HOME = Join-Path $projectRoot ".tools\maven\apache-maven-3.9.16"
$mysqlBin = Join-Path $projectRoot ".tools\mysql\mysql-8.0.43-winx64\bin"
$env:Path = "$env:JAVA_HOME\bin;$env:MAVEN_HOME\bin;$mysqlBin;$env:Path"

Write-Host "JAVA_HOME=$env:JAVA_HOME"
Write-Host "MAVEN_HOME=$env:MAVEN_HOME"
Write-Host "MYSQL_BIN=$mysqlBin"
java -version
mvn -version
