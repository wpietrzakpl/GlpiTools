#Get public and private function definition files.
$Public = @(Get-ChildItem -Recurse -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Recurse -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$ModuleRoot = $PSScriptRoot

#Execute a scriptblock to load each function instead of dot sourcing
foreach ($file in @($Public + $Private)) {
    try {
        $ExecutionContext.InvokeCommand.InvokeScript(
            $false, 
            (
                [scriptblock]::Create(
                    [io.file]::ReadAllText(
                        $file.FullName,
                        [Text.Encoding]::UTF8
                    )
                )
            ), 
            $null, 
            $null
        )
    }
    catch {
        Write-Error "[$($file.Basename)] $($_.Exception.Message.ToString())"
    }
}