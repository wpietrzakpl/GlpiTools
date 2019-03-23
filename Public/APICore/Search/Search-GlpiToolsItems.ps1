<#
.SYNOPSIS
    Function is using GLPI Search Engine to get informations.
.DESCRIPTION
    Function is using GLPI Search Engine to get informations about:
    
    - Computer
    - Monitor
    - Software
    - NetworkEquipment
    - Peripheral
    - Printer
    - CartridgeItem
    - ConsumableItem
    - Phone
    - Rack
    - Enclosure
    - Pdu
    - User
    - Group
    
    Based on his names.
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    PSP 02/2019
#>

function Search-GlpiToolsItems {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [ValidateSet("Computer",
            "Monitor",
            "Software",
            "NetworkEquipment",
            "Peripheral",
            "Printer",
            "CartridgeItem",
            "ConsumableItem",
            "Phone",
            "Rack",
            "Enclosure",
            "Pdu",
            "Ticket",
            "Problem",
            "Change",
            "Ticketrecurrent",
            "Softwarelicense",
            "Supplier",
            "Budget",
            "Users",
            "Group",
            "Softwarelicense",
            "Budget",
            "Supplier",
            "Contact",
            "Contract",
            "Document",
            "Line",
            "Certificate",
            "Datacenter",
            "Project",
            "Reminder",
            "Rssfeed",
            "Knowbaseitem",
            "Reservationitem",
            "Report",
            "Savedsearch",
            "User",
            "Group",
            "Entity",
            "Rule",
            "Profile",
            "Queuednotification",
            "Savedsearch",
            "Slm",
            "Fieldunicity",
            "Crontask",
            "Mailcollector",
            "Link",
            "Plugin",
            "Location",
            "State",
            "Manufacturer",
            "Blacklist",
            "Blacklistedmailcontent",
            "Itilcategory",
            "Taskcategory",
            "Tasktemplate",
            "Solutiontype",
            "Requesttype",
            "Solutiontemplate",
            "Projectstate",
            "Projecttype",
            "Projecttasktype",
            "Projecttasktemplate",
            "Computertype",
            "Networkequipmenttype",
            "Printertype",
            "Monitortype",
            "Peripheraltype",
            "Phonetype",
            "Softwarelicensetype",
            "Cartridgeitemtype",
            "Consumableitemtype",
            "Contracttype",
            "Contacttype",
            "DeviceGenericType",
            "DeviceSensorType",
            "DeviceMemoryType",
            "Suppliertype",
            "Interfacetype",
            "DeviceCaseType",
            "Phonepowersupply",
            "Filesystem",
            "Certificatetype",
            "Budgettype",
            "DeviceSimcardType",
            "Linetype",
            "Racktype",
            "Computermodel",
            "Networkequipmentmodel",
            "Printermodel",
            "Monitormodel",
            "Peripheralmodel",
            "Phonemodel",
            "DeviceCaseModel",
            "DeviceControlModel",
            "DeviceDriveModel",
            "DeviceGenericModel",
            "DeviceGraphicCardModel",
            "DeviceHardDriveModel",
            "DeviceMemoryModel",
            "DeviceMotherBoardModel",
            "DeviceNetworkCardModel",
            "DevicePciModel",
            "DevicePowerSupplyModel",
            "DeviceProcessorModel",
            "DeviceSoundCardModel",
            "DeviceSensorModel",
            "Rackmodel",
            "Enclosuremodel",
            "Pdumodel",
            "Virtualmachinetype",
            "Virtualmachinesystem",
            "Virtualmachinestate",
            "Documentcategory",
            "Documenttype",
            "Businesscriticity",
            "Knowbaseitemcategory",
            "Calendar",
            "Holiday",
            "Operatingsystem",
            "Operatingsystemversion",
            "Operatingsystemservicepack",
            "Operatingsystemarchitecture",
            "Operatingsystemedition",
            "Operatingsystemkernel",
            "Operatingsystemkernelversion",
            "Autoupdatesystem",
            "Networkinterface",
            "Netpoint",
            "Domain",
            "Network",
            "Vlan",
            "Lineoperator",
            "Ipnetwork",
            "Fqdn",
            "Wifinetwork",
            "Networkname",
            "Softwarecategory",
            "Usertitle",
            "Usercategory",
            "Rulerightparameter",
            "Fieldblacklist",
            "Ssovariable",
            "Plug",
            "DeviceBattery",
            "DeviceCase",
            "DeviceControl",
            "DeviceDrive",
            "DeviceFirmware",
            "DeviceGeneric",
            "DeviceGraphicCard",
            "DeviceHardDrive",
            "DeviceMemory",
            "DeviceNetworkCard",
            "DevicePci",
            "DevicePowerSupply",
            "DeviceProcessor",
            "DeviceSensor",
            "DeviceSimcard",
            "DeviceSoundCard",
            "DeviceMotherboard",
            "Notificationtemplate",
            "Notification")]
        [String]$SearchFor,

        [parameter(Mandatory = $true)]
        [ValidateSet("contains",
            "equals",
            "notequals",
            "lessthan",
            "morethan",
            "under",
            "notunder")]
        [String]$SearchType,

        [parameter(Mandatory = $false,
            ValueFromPipeline = $true)]
        [String]$SearchField = 1,

        [parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [String]$SearchValue,

        [parameter(Mandatory = $false)]
        [Switch]$SearchInTrash
    )
    
    begin {
        $SearchArray = @()
        $IntermediateArray = @()

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken

        if ($SearchInTrash) {
            $Trash = 1
        }
        else {
            $Trash = 0
        }
        
        $ListSearchOptions = Get-GlpiToolsListSearchOptions -ListOptionsFor $SearchFor
    }
    
    process {
        
        $params = @{
            headers = @{
                'Content-Type'  = 'application/json'
                'App-Token'     = $AppToken
                'Session-Token' = $SessionToken
            }
            method  = 'get'
            uri     = "$($PathToGlpi)/search/$($SearchFor)?is_deleted=$($Trash)&as_map=0&criteria[0][field]=$($SearchField)&criteria[0][searchtype]=$($SearchType)&criteria[0][value]=$($SearchValue)&search=Search&itemtype=$($SearchFor)&range=0-9999999999999"
        }
            
        $SearchResult = Invoke-RestMethod @params
        $SearchResults = $SearchResult | Select-Object -ExpandProperty data

        foreach ($SearchItem in $SearchResults) {
            $SearchHash = [ordered]@{}
            $DataResult = $SearchItem.PSObject.Properties | Select-Object -Property Name, Value 

            foreach ($Data in $DataResult) {
                    
                $Property = $ListSearchOptions | Where-Object {$_.Id -eq $Data.Name } | Select-Object -ExpandProperty Name
                $Table = $ListSearchOptions | Where-Object {$_.Id -eq $Data.Name } | Select-Object -ExpandProperty Table
                $Value = $Data.Value

                if ($SearchHash.Keys -contains $Property) {
                    $NewProperty = $Property + "_" + $Table
                    $SearchHash.Add($NewProperty, $Value)
                } else {
                    $SearchHash.Add($Property, $Value)
                }
                
            }

            $object = [pscustomobject]$SearchHash
            $IntermediateArray += $object 
        }

        $IntermediateArray
        $IntermediateArray = @()
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}