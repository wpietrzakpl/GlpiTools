#
# Module manifest for module 'GlpiTools'
#
# Generated by: Wojciech Pietrzak
#
# Generated on: 2018-10-12
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '1.2.0'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'e1889130-cc90-4122-bd1c-c41a68c5a2ab'

# Author of this module
Author = 'Wojciech Pietrzak'

# Company or vendor of this module
CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) 2018 Wojciech Pietrzak. All rights reserved.'

# Description of the functionality provided by this module
Description = 'PowerShell module wrapping Glpi API methods in handy functions'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'None'

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('GlpiTools')

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Set-GlpiToolsConfig', 
    'Get-GlpiToolsConfig',
    'Set-GlpiToolsInitSession',
    'Set-GlpiToolsKillSession',
    'Get-GlpiToolsComputers',
    'Get-GlpiToolsEntities',
    'Get-GlpiToolsUsers',
    'Get-GlpiToolsFusionInventoryAgents',
    'Get-GlpiToolsDropdownsStatusesOfItems',
    'Search-GlpiToolsItems',
    'Get-GlpiToolsGroups',
    'Get-GlpiToolsDropdownsOSUpdateSources',
    'Get-GlpiToolsDropdownsComputerModels',
    'Get-GlpiToolsListSearchOptions',
    'Set-GlpiToolsChangeActiveEntities',
    'Set-GlpiToolsResetPasswordRequest',
    'Set-GlpiToolsPasswordReset',
    'Get-GlpiToolsMyProfiles',
    'Get-GlpiToolsActiveProfile',
    'Get-GlpiToolsPlugins',
    'Get-GlpiToolsSoftware',
    'Get-GlpiToolsDropdownsSoftwareCategory',
    'Set-GlpiToolsChangeActiveProfile',
    'Get-GlpiToolsProfiles',
    'Add-GlpiToolsItems',
    'Update-GlpiToolsItems',
    'Remove-GlpiToolsItems',
    'Get-GlpiToolsSystemConfig',
    'Get-GlpiToolsDocuments',
    'Get-GlpiToolsItemLogs',
    'Get-GlpiToolsAppsStructuresComponent',
    'Get-GlpiToolsAppsStructuresComponentTarget',
    'Get-GlpiToolsAppsStructuresComponentType',
    'Get-GlpiToolsAppsStructuresComponentState',
    'Get-GlpiToolsAppsStructuresComponentTechnic',
    'Get-GlpiToolsAppsStructuresComponentUser',
    'Get-GlpiToolsAppsStructuresComponentSla',
    'Get-GlpiToolsAppsStructuresComponentDb',
    'Get-GlpiToolsAppsStructuresComponentInstance',
    'Get-GlpiToolsAppsStructuresComponentLicense',
    'Get-GlpiToolsMonitors',
    'Get-GlpiToolsNetworkEquipments',
    'Get-GlpiToolsPeripherals',
    'Get-GlpiToolsPrinters',
    'Get-GlpiToolsCartridgeItems',
    'Get-GlpiToolsConsumableItems',
    'Get-GlpiToolsPhones',
    'Get-GlpiToolsRacks',
    'Get-GlpiToolsEnclosures',
    'Get-GlpiToolsPdus',
    'Get-GlpiToolsTickets',
    'Get-GlpiToolsProblems',
    'Get-GlpiToolsChanges',
    'Get-GlpiToolsRecurrentTickets',
    'Get-GlpiToolsDropdownsLocations',
    'Get-GlpiToolsDropdownsDomains',
    'Get-GlpiToolsDropdownsNetworks',
    'Get-GlpiToolsDropdownsComputerTypes',
    'Get-GlpiToolsDropdownsManufacturers',
    'Get-GlpiToolsSoftwareVersions',
    'Get-GlpiToolsComputerSoftwareVersions',
    'Get-GlpiToolsDropdownsMonitorModels',
    'Get-GlpiToolsFinancialAndAdministrativeInformations',
    'Get-GlpiToolsDropdownsBlacklists',
    'Get-GlpiToolsDropdownsBlacklistedMailContent',
    'Get-GlpiToolsDropdownsTicketCategories',
    'Get-GlpiToolsDropdownsUserTitles',
    'Get-GlpiToolsDropdownsUserCategories',
    'Get-GlpiToolsDropdownsOperatingSystems',
    'Get-GlpiToolsDropdownsOSVersions',
    'Get-GlpiToolsDropdownsOSServicePacks',
    'Get-GlpiToolsDropdownsOSArchitectures',
    'Get-GlpiToolsDropdownsOSEditions',
    'Get-GlpiToolsDropdownsOSKernels',
    'Get-GlpiToolsDropdownsOSKernelVersions',
    'Get-GlpiToolsDropdownsNetworkEquipmentModels',
    'Get-GlpiToolsDropdownsPrinterModels',
    'Get-GlpiToolsDropdownsPeripheralModels',
    'Get-GlpiToolsDropdownsPhoneModels',
    'Get-GlpiToolsDropdownsDeviceCaseModels',
    'Get-GlpiToolsDropdownsDeviceControlModels',
    'Get-GlpiToolsDropdownsDeviceDriveModels',
    'Get-GlpiToolsDropdownsDeviceGenericModels',
    'Get-GlpiToolsDropdownsDeviceGraphicCardModels',
    'Get-GlpiToolsDropdownsDeviceHardDriveModels',
    'Get-GlpiToolsDropdownsDeviceMemoryModels',
    'Get-GlpiToolsDropdownsDeviceMotherboardModels',
    'Get-GlpiToolsDropdownsDeviceNetworkCardModels',
    'Get-GlpiToolsDropdownsOtherComponentModels',
    'Get-GlpiToolsDropdownsDevicePowerSupplyModels',
    'Get-GlpiToolsDropdownsDeviceProcessorModels',
    'Get-GlpiToolsDropdownsDeviceSoundCardModels',
    'Get-GlpiToolsDropdownsDeviceSensorModels',
    'Get-GlpiToolsDropdownsRackModels',
    'Get-GlpiToolsDropdownsEnclosureModels',
    'Get-GlpiToolsDropdownsPduModels',
    'Get-GlpiToolsDropdownsTaskCategories',
    'Get-GlpiToolsDropdownsTaskTemplates',
    'Get-GlpiToolsDropdownsSolutionTypes',
    'Get-GlpiToolsDropdownsRequestSources',
    'Get-GlpiToolsDropdownsSolutionTemplates',
    'Get-GlpiToolsDropdownsProjectStates',
    'Get-GlpiToolsDropdownsProjectTypes',
    'Get-GlpiToolsDropdownsProjectTasksTypes',
    'Get-GlpiToolsDropdownsProjectTaskTemplates'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShellPlace/GlpiTools'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

