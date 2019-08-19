<#
.SYNOPSIS
    Function is using GLPI Search Engine to get informations.
.DESCRIPTION
    Function Search for specific component in GLPI
    Parameters are the names of options in GLPI
    Remember that, names used in cmdlet coming from glpi URL, and can be hard to understand, but most of them are intuitional.
    To get name you always have to look at the URL in GLPI, for example "http://glpi/front/computer.php" where "computer" is the name to use in parameter.
.PARAMETER SearchFor
    You can use this function with -SearchFor parameter.
    Using TAB button you can choose desired option.
.PARAMETER SearchType
    You can use this function with -SearchType parameter.
    Using TAB button you can choose desired option.
.PARAMETER SearchField
    You can use this function with -SearchField parameter.
    This is an optional parameter, default value is 1 which is called Name in GLPI.
    This parameter can take pipeline input, even from Get-GlpiToolsListSearchOptions cmdlet.
.PARAMETER SearchValue
    You can use this function with -SearchValue parameter.
    This parameter can take pipeline input.
    Provide value to the function, which is used to search for. 
.PARAMETER SearchTrash
    You can use this function with -SearchTrash parameter.
    This is an optional switch parameter.
.EXAMPLE
    PS C:\> Search-GlpiToolsItems -SearchFor Computer -SearchType contains -SearchValue DC
    Example will show every asset which contains value "DC" in the Name from Asset->Computers.
.EXAMPLE
    PS C:\> Search-GlpiToolsItems -SearchFor Computer -SearchType contains -SearchValue DC -SearchField 1 
    Example will show every asset which contains value "DC" in the Name from Asset->Computers.
    SearchFiled can be retrieved from Get-GlpiToolsListSearchOptions cmdlet, you can provide it throught pipeline.
.EXAMPLE
    PS C:\> Search-GlpiToolsItems -SearchFor Computer -SearchType contains -SearchValue DC -SearchField 1 -SearchInTrash
    Example will show every asset which contains value "DC" in the Name from Asset->Computers.
    SearchFiled can be retrieved from Get-GlpiToolsListSearchOptions cmdlet, you can provide it throught pipeline.
    SearchInTrash will allow you to search for assets from trash.    
.INPUTS
    Only for -SearchValue, and -SearchField.
.OUTPUTS
    Function returns PSCustomObject with property's of Search results from GLPI
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
        [ValidateSet("Yes", "No")]
        [String]$SearchInTrash = "No"
    )
    
    begin {
        $SearchArray = [System.Collections.ArrayList]::new()

        $AppToken = $Script:AppToken
        $PathToGlpi = $Script:PathToGlpi
        $SessionToken = $Script:SessionToken

        $AppToken = Get-GlpiToolsConfig | Select-Object -ExpandProperty AppToken
        $PathToGlpi = Get-GlpiToolsConfig | Select-Object -ExpandProperty PathToGlpi
        $SessionToken = Set-GlpiToolsInitSession | Select-Object -ExpandProperty SessionToken

        if ($SearchInTrash -eq "Yes") {
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
        
        try {
            $SearchResults = $SearchResult | Select-Object -ExpandProperty data -ErrorAction Stop
        } catch {

        }
        
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
            $SearchArray.Add($object)
        }

        $SearchArray
        $SearchArray = [System.Collections.ArrayList]::new()
    }
    
    end {
        Set-GlpiToolsKillSession -SessionToken $SessionToken
    }
}