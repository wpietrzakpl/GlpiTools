<#
.SYNOPSIS
    Function is getting informations about Computer Model from GLPI
.DESCRIPTION
    Function is based on Computer Model ID which you can find in GLPI website
    Returns object with property's of computer model
.PARAMETER ComputerModel
    This parameter can take pipline input, either, you can use this function with -ComputerModel keyword.
    Provide to this param Computer Model ID from GLPI Dropdowns -> Computer Models Bookmark
.EXAMPLE
    PS C:\Users\Wojtek> 326, 321 | Get-GlpiToolsComputerModel
    Function gets ComputerModel ID from GLPI from Pipline (u can pass many ID's like that), and return Computer Model object
.EXAMPLE
    PS C:\Users\Wojtek> Get-GlpiToolsComputerModel -ComputerModel 20
    Function gets ComputerModel ID from GLPI which is provided through -ComputerModel after Function type, and return Computer Model object
.INPUTS
    Computer Model ID which you can find in GLPI, or use this Function to convert ID returned from other Functions
.OUTPUTS
    Function returns PSCustomObject with property's of Computer Model from GLPI
.NOTES
    PSP 02/2019
#>

function Get-GlpiToolsComputerModel {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string[]]$ComputerModel
    )
    
    begin {
        $SessionToken = $Script:SessionToken
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $ComputerModelArray = @()
    }
    
    process {
        foreach ($CompModel in $ComputerModel) {
            $params = @{
                headers = @{
                    'Content-Type'  = 'application/json'
                    'App-Token'     = $AppToken
                    'Session-Token' = $SessionToken
                }
                method  = 'get'
                uri     = "$($PathToGlpi)/ComputerModel/$($CompModel)"
            }
            try {
                $CompModel = Invoke-RestMethod @params -ErrorAction Stop

                $CompModelHash = [ordered]@{
                    'Id'               = $CompModel.id
                    'Name'             = $CompModel.name
                    'Comment'          = $CompModel.comment
                    'ProductNumber'    = $CompModel.product_number
                    'Weight'           = $CompModel.weight
                    'RequiredUnits'    = $CompModel.required_units
                    'Depth'            = $CompModel.depth
                    'PowerConnections' = $CompModel.power_connections
                    'PowerConsumption' = $CompModel.power_consumption
                    'IsHalfRack'       = $CompModel.is_half_rack
                    'PictureFront'     = $CompModel.picture_front
                    'PictureRear'      = $CompModel.picture_rear
                    'DateMod'          = $CompModel.date_mod
                    'DateCreation'     = $CompModel.date_creation
                }
                $object = New-Object -TypeName PSCustomObject -Property $CompModelHash
                $ComputerModelArray += $object
            }
            catch {
                $CompModelHash = [ordered]@{
                    'Id'               = $CompModel
                    'Name'             = $CompModel.name
                    'Comment'          = $CompModel.comment
                    'ProductNumber'    = $CompModel.product_number
                    'Weight'           = $CompModel.weight
                    'RequiredUnits'    = $CompModel.required_units
                    'Depth'            = $CompModel.depth
                    'PowerConnections' = $CompModel.power_connections
                    'PowerConsumption' = $CompModel.power_consumption
                    'IsHalfRack'       = $CompModel.is_half_rack
                    'PictureFront'     = $CompModel.picture_front
                    'PictureRear'      = $CompModel.picture_rear
                    'DateMod'          = $CompModel.date_mod
                    'DateCreation'     = $CompModel.date_creation
                }
                $object = New-Object -TypeName PSCustomObject -Property $CompModelHash
                $ComputerModelArray += $object
            }   
        }
    }
    
    end {
        $ComputerModelArray
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}