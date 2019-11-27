<#
.SYNOPSIS
    Function is getting Problem informations from GLPI
.DESCRIPTION
    Function is based on ProblemID which you can find in GLPI website
    Returns object with property's of Problem
.PARAMETER All
    This parameter will return all Problems from GLPI
.PARAMETER ProblemId
    This parameter can take pipline input, either, you can use this function with -ProblemId keyword.
    Provide to this param Problem ID from GLPI Problems Bookmark
.PARAMETER Raw
    Parameter which you can use with ProblemId Parameter.
    ProblemId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER ProblemName
    Provide to this param Problem Name from GLPI Problems Bookmark
.PARAMETER SearchInTrash
    Parameter which you can use with ProblemName Parameter.
    If you want Search for Problem name in trash, that parameter allow you to do it.
.PARAMETER Parameter
    Parameter which you can use with ProblemId Parameter. 
    If you want to get additional parameter of Problem object like, disks, or logs, use this parameter.
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsProblems
    Function gets ProblemID from GLPI from Pipline, and return Problem object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsProblems
    Function gets ProblemID from GLPI from Pipline (u can pass many ID's like that), and return Problem object
.EXAMPLE
    PS C:\> Get-GlpiToolsProblems -ProblemId 326
    Function gets ProblemID from GLPI which is provided through -ProblemId after Function type, and return Problem object
.EXAMPLE 
    PS C:\> Get-GlpiToolsProblems -ProblemId 326, 321
    Function gets ProblemID from GLPI which is provided through -ProblemId keyword after Function type (u can provide many ID's like that), and return Problem object
.EXAMPLE
    PS C:\> Get-GlpiToolsProblems -ProblemId 234 -Raw
    Example will show Problem with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> 234 | Get-GlpiToolsProblems -Raw
    Example will show Problem with id 234, but without any parameter converted
.EXAMPLE
    PS C:\> Get-GlpiToolsProblems -ProblemName glpi
    Example will return glpi Problem, but what is the most important, Problem will be shown exacly as you see in glpi Problems tab.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.EXAMPLE
    PS C:\> Get-GlpiToolsProblems -ProblemName glpi -SearchInTrash Yes
    Example will return glpi Problem, but from trash
.INPUTS
    Problem ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Problems from GLPI
.NOTES
    PSP 05/2019
#>

function Get-GlpiToolsProblems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "ProblemId")]
        [alias('PID')]
        [string[]]$ProblemId,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProblemId")]
        [switch]$Raw,

        [parameter(Mandatory = $true,
            ParameterSetName = "ProblemName")]
        [alias('PN')]
        [string]$ProblemName,
        [parameter(Mandatory = $false,
            ParameterSetName = "ProblemName")]
        [alias('SIT')]
        [ValidateSet("Yes", "No")]
        [string]$SearchInTrash = "No",

        [parameter(Mandatory = $false,
            ParameterSetName = "ProblemId")]
        [alias('Param')]
        [ValidateSet("ExpandDropdowns",
            "GetHateoas",
            "GetSha1",
            "WithDevices",
            "WithInfocoms",
            "WithContracts",
            "WithDocuments",
            "WithProblems",
            "WithProblems",
            "WithChanges",
            "WithNotes",
            "WithLogs")]
        [string]$Parameter
    )
    
    begin {

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig -Verbose:$false | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession -Verbose:$false | Select-Object -ExpandProperty SessionToken

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ProblemObjectArray = [System.Collections.Generic.List[PSObject]]::New()

        switch ($Parameter) {
            ExpandDropdowns { $ParamValue = "?expand_dropdowns=true" }
            GetHateoas { $ParamValue = "?get_hateoas=true" }
            GetSha1 { $ParamValue = "?get_sha1=true" }
            WithDevices { $ParamValue = "?with_devices=true" }
            WithInfocoms { $ParamValue = "?with_infocoms=true" }
            WithContracts { $ParamValue = "?with_contracts=true" }
            WithDocuments { $ParamValue = "?with_documents=true" }
            WithProblems { $ParamValue = "?with_Problems=true" } 
            WithProblems { $ParamValue = "?with_problems=true" }
            WithChanges { $ParamValue = "?with_changes=true" }
            WithNotes { $ParamValue = "?with_notes=true" } 
            WithLogs { $ParamValue = "?with_logs=true" }
            Default { $ParamValue = "" }
        }

    }
    
    process {
        switch ($ChoosenParam) {
            All { 
                $params = @{
                    headers = @{
                        'Content-Type'  = 'application/json'
                        'App-Token'     = $AppToken
                        'Session-Token' = $SessionToken
                    }
                    method  = 'get'
                    uri     = "$($PathToGlpi)/Problem/?range=0-9999999999999"
                }
                
                $GlpiProblemAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($GlpiProblem in $GlpiProblemAll) {
                    $ProblemHash = [ordered]@{ }
                            $ProblemProperties = $GlpiProblem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProblemProp in $ProblemProperties) {
                                $ProblemHash.Add($ProblemProp.Name, $ProblemProp.Value)
                            }
                            $object = [pscustomobject]$ProblemHash
                            $ProblemObjectArray.Add($object)
                }
                $ProblemObjectArray
                $ProblemObjectArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            ProblemId { 
                foreach ( $PId in $ProblemId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/Problem/$($PId)$ParamValue"
                    }

                    Try {
                        $GlpiProblem = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $ProblemHash = [ordered]@{ }
                            $ProblemProperties = $GlpiProblem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProblemProp in $ProblemProperties) {
                                $ProblemHash.Add($ProblemProp.Name, $ProblemProp.Value)
                            }
                            $object = [pscustomobject]$ProblemHash
                            $ProblemObjectArray.Add($object)
                        } else {
                            $ProblemHash = [ordered]@{ }
                            $ProblemProperties = $GlpiProblem.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($ProblemProp in $ProblemProperties) {

                                $ProblemPropNewValue = Get-GlpiToolsParameters -Parameter $ProblemProp.Name -Value $ProblemProp.Value

                                $ProblemHash.Add($ProblemProp.Name, $ProblemPropNewValue)
                            }
                            $object = [pscustomobject]$ProblemHash
                            $ProblemObjectArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "Problem ID = $PId is not found"
                        
                    }
                    $ProblemObjectArray
                    $ProblemObjectArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            ProblemName { 
                Search-GlpiToolsItems -SearchFor Problem -SearchType contains -SearchValue $ProblemName -SearchInTrash $SearchInTrash
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken -Verbose:$false
    }
}