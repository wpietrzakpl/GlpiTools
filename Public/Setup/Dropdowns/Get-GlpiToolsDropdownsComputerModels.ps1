<#
.SYNOPSIS
    Function is getting Computer Models informations from GLPI
.DESCRIPTION
    Function is based on ComputerModelsID which you can find in GLPI website
    Returns object with property's of Computer Models
.PARAMETER All
    This parameter will return all Computer Models from GLPI
.PARAMETER ComputerModelsId
    This parameter can take pipline input, either, you can use this function with -ComputerModelsId keyword.
    Provide to this param Computer Models ID from GLPI Computer Models Bookmark
.PARAMETER ComputerModelsName
    This parameter can take pipline input, either, you can use this function with -ComputerModelsName keyword.
    Provide to this param Computer Models Name from GLPI Computer Models Bookmark
.EXAMPLE
    PS C:\Users\Wojtek> 326 | Get-GlpiToolsDropdownsComputerModels
    Function gets ComputerModelsId from GLPI from Pipline, and return Computer Models object
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsDropdownsComputerModels
    Function gets ComputerModelsId from GLPI from Pipline (u can pass many ID's like that), and return Computer Models object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsDropdownsComputerModels -ComputerModelsId 326
    Function gets ComputerModelsId from GLPI which is provided through -ComputerModelsId after Function type, and return Computer Models object
.EXAMPLE 
    PS C:\Users\Wojtek> Get-GlpiToolsDropdownsComputerModels -ComputerModelsId 326, 321
    Function gets ComputerModelsId from GLPI which is provided through -ComputerModelsId keyword after Function type (u can provide many ID's like that), and return Computer Models object
.INPUTS
    Computer Models ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Computer Models from GLPI
.NOTES
    PSP 03/2019
#>

function Get-GlpiToolsDropdownsComputerModels {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $false,
        ParameterSetName = "All")]
        [switch]$All,
        [parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ParameterSetName = "ComputerModelsId")]
        [alias('CMID')]
        [string[]]$ComputerModelsId,
        [parameter(Mandatory = $true,
        ParameterSetName = "ComputerModelsName")]
        [alias('CMN')]
        [string[]]$ComputerModelsName
    )
    
    begin {
        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ChoosenParam = ($PSCmdlet.MyInvocation.BoundParameters).Keys

        $ComputerModelsArray = @()
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
                    uri     = "$($PathToGlpi)/computermodel/?range=0-99999999999"
                }
                
                $GlpiComputerModelsAll = Invoke-RestMethod @params

                foreach ($GlpiComputerModels in $GlpiComputerModelsAll) {
                    $ComputerModelsHash = [ordered]@{
                        'Id'                = $GlpiComputerModels.id
                        'Name'              = $GlpiComputerModels.name
                        'Comment'           = $GlpiComputerModels.comment
                        'ProductNumber'     = $GlpiComputerModels.product_number
                        'Weight'            = $GlpiComputerModels.weight
                        'RequiredUnits'     = $GlpiComputerModels.required_units
                        'Depth'             = $GlpiComputerModels.depth
                        'PowerConnections'  = $GlpiComputerModels.power_connections
                        'PowerConsumption'  = $GlpiComputerModels.power_consumption
                        'IsHalfRack'        = $GlpiComputerModels.is_half_rack
                        'PictureFront'      = $GlpiComputerModels.picture_front
                        'PictureRear'       = $GlpiComputerModels.picture_rear
                        'DateMod'           = $GlpiComputerModels.date_mod
                        'DateCreation'      = $GlpiComputerModels.date_creation
                    }
                    $object = New-Object -TypeName PSCustomObject -Property $ComputerModelsHash
                    $ComputerModelsArray += $object
                }
                $ComputerModelsArray
                $ComputerModelsArray = @()
            }
            ComputerModelsId { 
                foreach ( $CMId in $ComputerModelsId ) {
                    $params = @{
                        headers = @{
                            'Content-Type'  = 'application/json'
                            'App-Token'     = $AppToken
                            'Session-Token' = $SessionToken
                        }
                        method  = 'get'
                        uri     = "$($PathToGlpi)/computermodel/$($CMId)"
                    }
                
                    try {
                        $GlpiComputerModels = Invoke-RestMethod @params -ErrorAction Stop
                        $ComputerModelsHash = [ordered]@{
                            'Id'                = $GlpiComputerModels.id
                            'Name'              = $GlpiComputerModels.name
                            'Comment'           = $GlpiComputerModels.comment
                            'ProductNumber'     = $GlpiComputerModels.product_number
                            'Weight'            = $GlpiComputerModels.weight
                            'RequiredUnits'     = $GlpiComputerModels.required_units
                            'Depth'             = $GlpiComputerModels.depth
                            'PowerConnections'  = $GlpiComputerModels.power_connections
                            'PowerConsumption'  = $GlpiComputerModels.power_consumption
                            'IsHalfRack'        = $GlpiComputerModels.is_half_rack
                            'PictureFront'      = $GlpiComputerModels.picture_front
                            'PictureRear'       = $GlpiComputerModels.picture_rear
                            'DateMod'           = $GlpiComputerModels.date_mod
                            'DateCreation'      = $GlpiComputerModels.date_creation
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $ComputerModelsHash
                        $ComputerModelsArray += $object
                    }
                    catch {
                        $ComputerModelsHash = [ordered]@{
                            'Id'                = $CMId
                            'Name'              = ' '
                            'Comment'           = ' '
                            'ProductNumber'     = ' '
                            'Weight'            = ' '
                            'RequiredUnits'     = ' '
                            'Depth'             = ' '
                            'PowerConnections'  = ' '
                            'PowerConsumption'  = ' '
                            'IsHalfRack'        = ' '
                            'PictureFront'      = ' '
                            'PictureRear'       = ' '
                            'DateMod'           = ' '
                            'DateCreation'      = ' '
                        }
                        $object = New-Object -TypeName PSCustomObject -Property $ComputerModelsHash
                        $ComputerModelsArray += $object  
                    }
                }
                $ComputerModelsArray
                $ComputerModelsArray = @()
            }
            ComputerModelsName { 
                # here search function 
            }
            Default {
                
            }
        }
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}