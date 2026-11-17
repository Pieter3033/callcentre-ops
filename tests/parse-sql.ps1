param([string]$ReportPath)
$ErrorActionPreference = 'Stop'
# Offline Microsoft parser. This script never opens a database connection.
$assembly = $env:SQL_SCRIPTDOM_ASSEMBLY
if (-not $assembly) { throw 'Set SQL_SCRIPTDOM_ASSEMBLY to the local Microsoft ScriptDom DLL path.' }
Add-Type -Path $assembly
$parser = [Microsoft.SqlServer.TransactSql.ScriptDom.TSql160Parser]::new($true)
$root = Split-Path $PSScriptRoot -Parent
$results = foreach ($file in Get-ChildItem -LiteralPath (Join-Path $root 'database') -Filter '*.sql*') {
 $reader = [System.IO.StringReader]::new([System.IO.File]::ReadAllText($file.FullName))
 $errors = $null
 $null = $parser.Parse($reader,[ref]$errors)
 $reader.Dispose()
 [pscustomobject]@{ File=$file.Name; Passed=($errors.Count -eq 0); Errors=@($errors | ForEach-Object { [pscustomobject]@{Line=$_.Line;Column=$_.Column;Number=$_.Number;Message=$_.Message} }) }
}
if ($ReportPath) { $results | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ReportPath -Encoding utf8 }
$results | ConvertTo-Json -Depth 5
if (@($results | Where-Object { -not $_.Passed }).Count) { exit 1 }
