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
            
            $Id = $State | Select-Object -ExpandProperty id
            $Name = $State | Select-Object -ExpandProperty name
            $EntitiesId = $State | Select-Object -ExpandProperty entities_id
            $IsRecursive = $State | Select-Object -ExpandProperty is_recursive
            $Comment = $State | Select-Object -ExpandProperty comment
            $StatesId = $State | Select-Object -ExpandProperty states_id 
            $CompleteName = $State | Select-Object -ExpandProperty completename
            $Level = $State | Select-Object -ExpandProperty level
            $AncestorsCache = $State | Select-Object -ExpandProperty ancestors_cache 
            $SonsCache = $State | Select-Object -ExpandProperty sons_cache
            $IsVisibleComputer = $State | Select-Object -ExpandProperty is_visible_computer
            $IsVisibleMonitor = $State | Select-Object -ExpandProperty is_visible_monitor
            $IsVisibleNetworkEquipment = $State | Select-Object -ExpandProperty is_visible_networkequipment
            $IsVisiblePeripherial = $State | Select-Object -ExpandProperty is_visible_peripheral
            $IsVisiblePhone = $State | Select-Object -ExpandProperty is_visible_phone 
            $IsVisiblePrinter = $State | Select-Object -ExpandProperty is_visible_printer 
            $IsVisibleSoftwareVersion = $State | Select-Object -ExpandProperty is_visible_softwareversion
            $IsVisibleSoftwareLicence = $State | Select-Object -ExpandProperty is_visible_softwarelicense
            $IsVisibleLine = $State | Select-Object -ExpandProperty is_visible_line
            $IsVisibleCertificate = $State | Select-Object -ExpandProperty is_visible_certificate
            $IsVisibleRack = $State | Select-Object -ExpandProperty is_visible_rack
            $IsVisibleEnclosure = $State | Select-Object -ExpandProperty is_visible_enclosure
            $IsVisiblePdu = $State | Select-Object -ExpandProperty is_visible_pdu
            $DateMod = $State | Select-Object -ExpandProperty date_mod 
            $DateCreation = $State | Select-Object -ExpandProperty date_creation 

            $object = New-Object -TypeName PSCustomObject
            $object | Add-Member -Name 'Id' -MemberType NoteProperty -Value $Id
            $object | Add-Member -Name 'Name' -MemberType NoteProperty -Value $Name
            $object | Add-Member -Name 'EntitiesId' -MemberType NoteProperty -Value $EntitiesId
            $object | Add-Member -Name 'IsRecursive' -MemberType NoteProperty -Value $IsRecursive
            $object | Add-Member -Name 'Comment' -MemberType NoteProperty -Value $Comment
            $object | Add-Member -Name 'StatesId' -MemberType NoteProperty -Value $StatesId
            $object | Add-Member -Name 'CompleteName' -MemberType NoteProperty -Value $CompleteName
            $object | Add-Member -Name 'Level' -MemberType NoteProperty -Value $Level
            $object | Add-Member -Name 'AncestorsCache' -MemberType NoteProperty -Value $AncestorsCache
            $object | Add-Member -Name 'SonsCache' -MemberType NoteProperty -Value $SonsCache
            $object | Add-Member -Name 'IsVisibleComputer' -MemberType NoteProperty -Value $IsVisibleComputer
            $object | Add-Member -Name 'IsVisibleMonitor' -MemberType NoteProperty -Value $IsVisibleMonitor
            $object | Add-Member -Name 'IsVisibleNetworkEquipment' -MemberType NoteProperty -Value $IsVisibleNetworkEquipment
            $object | Add-Member -Name 'IsVisiblePeripherial' -MemberType NoteProperty -Value $IsVisiblePeripherial
            $object | Add-Member -Name 'IsVisiblePhone' -MemberType NoteProperty -Value $IsVisiblePhone
            $object | Add-Member -Name 'IsVisiblePrinter' -MemberType NoteProperty -Value $IsVisiblePrinter
            $object | Add-Member -Name 'IsVisibleSoftwareVersion' -MemberType NoteProperty -Value $IsVisibleSoftwareVersion
            $object | Add-Member -Name 'IsVisibleSoftwareLicence' -MemberType NoteProperty -Value $IsVisibleSoftwareLicence
            $object | Add-Member -Name 'IsVisibleLine' -MemberType NoteProperty -Value $IsVisibleLine
            $object | Add-Member -Name 'IsVisibleCertificate' -MemberType NoteProperty -Value $IsVisibleCertificate
            $object | Add-Member -Name 'IsVisibleRack' -MemberType NoteProperty -Value $IsVisibleRack
            $object | Add-Member -Name 'IsVisibleEnclosure' -MemberType NoteProperty -Value $IsVisibleEnclosure
            $object | Add-Member -Name 'IsVisiblePdu' -MemberType NoteProperty -Value $IsVisiblePdu
            $object | Add-Member -Name 'DateMod' -MemberType NoteProperty -Value $DateMod
            $object | Add-Member -Name 'DateCreation' -MemberType NoteProperty -Value $DateCreation
            $StatesArray += $object 

        }

        $StatesArray
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}