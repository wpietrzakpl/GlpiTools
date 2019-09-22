<#
.SYNOPSIS
    Function is getting States of the virtual machine informations from GLPI
.DESCRIPTION
    Function is based on StateOfTheVirtualMachineId which you can find in GLPI website
    Returns object with property's of States of the virtual machine
.PARAMETER All
    This parameter will return all States of the virtual machine from GLPI
.PARAMETER StateOfTheVirtualMachineId
    This parameter can take pipeline input, either, you can use this function with -StateOfTheVirtualMachineId keyword.
    Provide to this param StateOfTheVirtualMachineId from GLPI States of the virtual machine Bookmark
.PARAMETER Raw
    Parameter which you can use with StateOfTheVirtualMachineId Parameter.
    StateOfTheVirtualMachineId has converted parameters from default, parameter Raw allows not convert this parameters.
.PARAMETER StateOfTheVirtualMachineName
    This parameter can take pipeline input, either, you can use this function with -StateOfTheVirtualMachineId keyword.
    Provide to this param States of the virtual machine Name from GLPI States of the virtual machine Bookmark
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsStatesOfTheVirtualMachine -All
    Example will return all States of the virtual machine from Glpi
.EXAMPLE
    PS C:\> 326 | Get-GlpiToolsDropdownsStatesOfTheVirtualMachine
    Function gets StateOfTheVirtualMachineId from GLPI from pipeline, and return States of the virtual machine object
.EXAMPLE
    PS C:\> 326, 321 | Get-GlpiToolsDropdownsStatesOfTheVirtualMachine
    Function gets StateOfTheVirtualMachineId from GLPI from pipeline (u can pass many ID's like that), and return States of the virtual machine object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsStatesOfTheVirtualMachine -StateOfTheVirtualMachineId 326
    Function gets StateOfTheVirtualMachineId from GLPI which is provided through -StateOfTheVirtualMachineId after Function type, and return States of the virtual machine object
.EXAMPLE 
    PS C:\> Get-GlpiToolsDropdownsStatesOfTheVirtualMachine -StateOfTheVirtualMachineId 326, 321
    Function gets States of the virtual machine Id from GLPI which is provided through -StateOfTheVirtualMachineId keyword after Function type (u can provide many ID's like that), and return States of the virtual machine object
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsStatesOfTheVirtualMachine -StateOfTheVirtualMachineName Fusion
    Example will return glpi States of the virtual machine, but what is the most important, States of the virtual machine will be shown exactly as you see in glpi dropdown States of the virtual machine.
    If you want to add parameter, you have to modify "default items to show". This is the "key/tool" icon near search.
.INPUTS
    States of the virtual machine ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of States of the virtual machine from GLPI
.NOTES
    PSP 09/2019
#>

function Get-GlpiToolsDropdownsStatesOfTheVirtualMachine {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
            ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "StateOfTheVirtualMachineId")]
        [alias('SOTVMID')]
        [string[]]$StateOfTheVirtualMachineId,
        [parameter(Mandatory = $false,
            ParameterSetName = "StateOfTheVirtualMachineId")]
        [switch]$Raw,
        
        [parameter(Mandatory = $true,
            ParameterSetName = "StateOfTheVirtualMachineName")]
        [alias('SOTVMN')]
        [string]$StateOfTheVirtualMachineName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $StatesOfTheVirtualMachineArray = [System.Collections.Generic.List[PSObject]]::New()
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
                    uri     = "$($PathToGlpi)/virtualmachinestate/?range=0-9999999999999"
                }
                
                $StatesOfTheVirtualMachineAll = Invoke-RestMethod @params -Verbose:$false

                foreach ($StateOfTheVirtualMachine in $StatesOfTheVirtualMachineAll) {
                    $StateOfTheVirtualMachineHash = [ordered]@{ }
                    $StateOfTheVirtualMachineProperties = $StateOfTheVirtualMachine.PSObject.Properties | Select-Object -Property Name, Value 
                                
                    foreach ($StateOfTheVirtualMachineProp in $StateOfTheVirtualMachineProperties) {
                        $StateOfTheVirtualMachineHash.Add($StateOfTheVirtualMachineProp.Name, $StateOfTheVirtualMachineProp.Value)
                    }
                    $object = [pscustomobject]$StateOfTheVirtualMachineHash
                    $StatesOfTheVirtualMachineArray.Add($object)
                }
                $StatesOfTheVirtualMachineArray
                $StatesOfTheVirtualMachineArray = [System.Collections.Generic.List[PSObject]]::New()
            }
            StateOfTheVirtualMachineId { 
                foreach ( $SOTVMId in $StateOfTheVirtualMachineId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/virtualmachinestate/$($SOTVMId)"
                    }

                    Try {
                        $StateOfTheVirtualMachine = Invoke-RestMethod @params -ErrorAction Stop

                        if ($Raw) {
                            $StateOfTheVirtualMachineHash = [ordered]@{ }
                            $StateOfTheVirtualMachineProperties = $StateOfTheVirtualMachine.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($StateOfTheVirtualMachineProp in $StateOfTheVirtualMachineProperties) {
                                $StateOfTheVirtualMachineHash.Add($StateOfTheVirtualMachineProp.Name, $StateOfTheVirtualMachineProp.Value)
                            }
                            $object = [pscustomobject]$StateOfTheVirtualMachineHash
                            $StatesOfTheVirtualMachineArray.Add($object)
                        } else {
                            $StateOfTheVirtualMachineHash = [ordered]@{ }
                            $StateOfTheVirtualMachineProperties = $StateOfTheVirtualMachine.PSObject.Properties | Select-Object -Property Name, Value 
                                
                            foreach ($StateOfTheVirtualMachineProp in $StateOfTheVirtualMachineProperties) {

                                $StateOfTheVirtualMachinePropNewValue = Get-GlpiToolsParameters -Parameter $StateOfTheVirtualMachineProp.Name -Value $StateOfTheVirtualMachineProp.Value

                                $StateOfTheVirtualMachineHash.Add($StateOfTheVirtualMachineProp.Name, $StateOfTheVirtualMachinePropNewValue)
                            }
                            $object = [pscustomobject]$StateOfTheVirtualMachineHash
                            $StatesOfTheVirtualMachineArray.Add($object)
                        }
                    } Catch {

                        Write-Verbose -Message "State Of The Virtual Machine ID = $SOTVMId is not found"
                        
                    }
                    $StatesOfTheVirtualMachineArray
                    $StatesOfTheVirtualMachineArray = [System.Collections.Generic.List[PSObject]]::New()
                }
            }
            StateOfTheVirtualMachineName { 
                Search-GlpiToolsItems -SearchFor virtualmachinestate -SearchType contains -SearchValue $StateOfTheVirtualMachineName
            } 
            Default { }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}