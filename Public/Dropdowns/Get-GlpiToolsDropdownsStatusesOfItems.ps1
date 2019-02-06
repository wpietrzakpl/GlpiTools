<#
.SYNOPSIS
    Function gets statuses of items
.DESCRIPTION
    Function gets statuses of items which can be defined in dropowns
.PARAMETER StatesId
    This parameter can take pipline input, either, you can use this function with -StatesId keyword.
    Provide to this param States ID from GLPI Dropdowns -> Statuses Of Items
.EXAMPLE
    PS C:\> Get-GlpiToolsDropdownsStatusesOfItems
    Function will show all statuses of items
.INPUTS
    None
.OUTPUTS
    Function returns PSCustomObject with statuses of items from GLPI 
.NOTES
    PSP 01/2019
#>

function Get-GlpiToolsDropdownsStatusesOfItems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ParameterSetName = "StatesId")]
        [alias('SID')]
        [string[]]$StatesId
    )
    
    begin {

        $SessionToken = $Script:SessionToken    
        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi

        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken
        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi

        $StatesArray = @()
    }
    
    process {
        # ZROBIC TUTAJ SWITCHA z ALL, ID, PO NAZWIE
        foreach ($Id in $StatesId) {
            $params = @{
                headers = @{
                    'Content-Type'  = 'application/json'
                    'App-Token'     = $AppToken
                    'Session-Token' = $SessionToken
                }
                method  = 'get'
                uri     = "$($PathToGlpi)/State/$($Id)"
            }
            $State = Invoke-RestMethod @params
            
            $StateHash = [ordered]@{
                'Id' = $State.id
                'Name' = $State.name
                'EntitiesId' = $State.entities_id
                'IsRecursive' = $State.is_recursive
                'Comment' = $State.comment
                'StatesId' = $State.states_id 
                'CompleteName' = $State.completename
                'Level' = $State.level
                'AncestorsCache' = $State.ancestors_cache 
                'SonsCache' = $State.sons_cache
                'IsVisibleComputer' = $State.is_visible_computer
                'IsVisibleMonitor' = $State.is_visible_monitor
                'IsVisibleNetworkEquipment' = $State.is_visible_networkequipment
                'IsVisiblePeripherial' = $State.is_visible_peripheral
                'IsVisiblePhone' = $State.is_visible_phone 
                'IsVisiblePrinter' = $State.is_visible_printer 
                'IsVisibleSoftwareVersion' = $State.is_visible_softwareversion
                'IsVisibleSoftwareLicence' = $State.is_visible_softwarelicense
                'IsVisibleLine' = $State.is_visible_line
                'IsVisibleCertificate' = $State.is_visible_certificate
                'IsVisibleRack' = $State.is_visible_rack
                'IsVisibleEnclosure' = $State.is_visible_enclosure
                'IsVisiblePdu' = $State.is_visible_pdu
                'DateMod' = $State.date_mod 
                'DateCreation' = $State.date_creation 
            }
            $object = New-Object -TypeName PSCustomObject -Property $StateHash
            $StatesArray += $object 

        }

        $StatesArray
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}