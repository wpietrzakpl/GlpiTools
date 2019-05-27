# GlpiTools
<div align="center">
<!-- Discord -->
  <a href="https://discord.gg/u4YdyVb">
    <img src="https://img.shields.io/discord/235574673155293194.svg?style=flat&label=Discord&logo=discord"
      alt="Discord - Chat" title="Discord - Chat" />
  </a>&nbsp;&nbsp;&nbsp;&nbsp;
</div>

## Abstract

PowerShell Module which wrap Glpi API into handy functions.
Module works on Windows or Linux with PowerShell Core. 

***

## Prerequisites

 * Enable API - **You can do this here** - Setup -> General -> API -] Enable Rest API
 * Configure Access From Localhost - **You can do this here** - Setup -> General -> API -> full access from localhost -] Filter access (I prefere to leave parameters, IPv4, IPv6 blank)
 * Get app_token - **You can do this here** - Setup -> General -> API -> full access from localhost -] Filter access (parameter Application token(app_token), click regenerate checkbox and save, after that app_token will show. Copy token and save it for later use)
 * Get User API token - **You can do this here** - Administration -> Users - (user) -> Settings -] Remote access keys (parameter API token, click regenerate checkbox and save, after that User Token will show. Copy token and save it for later use) - ! Remember that user must have permissions to do what u want to do with API

 ## Instalation

 To install\import module you have to:
 
 * Download module from GitHub.
 * Unzip module, remove GitHub branch name from the name of directory, and copy into folder which you have configured to store modules, you can find the path running command in PowerShell ``` $env:PSModulePath -split ";" ```
 * To import module into active powershell session you have to use command ` Import-Module GlpiTools `
 * Or if you want to install module you have to use command ` Install-Module GlpiTools `
 * Configure Module to later use with command `Set-GlpiToolsConfig`, pass to the command tokens and url which you have from Prerequisites section

 After those steps, you can start to use module

 ## Available commands

 ```
 Key                                          Value
 ---                                          -----
 Add-GlpiToolsItems                           Add-GlpiToolsItems
 Get-GlpiToolsActiveProfile                   Get-GlpiToolsActiveProfile
 Get-GlpiToolsAppsStructuresComponent         Get-GlpiToolsAppsStructuresComponent
 Get-GlpiToolsAppsStructuresComponentDb       Get-GlpiToolsAppsStructuresComponentDb
 Get-GlpiToolsAppsStructuresComponentInstance Get-GlpiToolsAppsStructuresComponentInstance
 Get-GlpiToolsAppsStructuresComponentLicense  Get-GlpiToolsAppsStructuresComponentLicense
 Get-GlpiToolsAppsStructuresComponentSla      Get-GlpiToolsAppsStructuresComponentSla
 Get-GlpiToolsAppsStructuresComponentState    Get-GlpiToolsAppsStructuresComponentState
 Get-GlpiToolsAppsStructuresComponentTarget   Get-GlpiToolsAppsStructuresComponentTarget
 Get-GlpiToolsAppsStructuresComponentTechnic  Get-GlpiToolsAppsStructuresComponentTechnic
 Get-GlpiToolsAppsStructuresComponentType     Get-GlpiToolsAppsStructuresComponentType
 Get-GlpiToolsAppsStructuresComponentUser     Get-GlpiToolsAppsStructuresComponentUser
 Get-GlpiToolsCartridgeItems                  Get-GlpiToolsCartridgeItems
 Get-GlpiToolsComputers                       Get-GlpiToolsComputers
 Get-GlpiToolsConfig                          Get-GlpiToolsConfig
 Get-GlpiToolsConsumableItems                 Get-GlpiToolsConsumableItems
 Get-GlpiToolsDocuments                       Get-GlpiToolsDocuments
 Get-GlpiToolsDropdownsComputerModels         Get-GlpiToolsDropdownsComputerModels
 Get-GlpiToolsDropdownsSoftwareCategory       Get-GlpiToolsDropdownsSoftwareCategory
 Get-GlpiToolsDropdownsStatusesOfItems        Get-GlpiToolsDropdownsStatusesOfItems
 Get-GlpiToolsDropdownsUpdateSources          Get-GlpiToolsDropdownsUpdateSources
 Get-GlpiToolsEnclosures                      Get-GlpiToolsEnclosures
 Get-GlpiToolsEntities                        Get-GlpiToolsEntities
 Get-GlpiToolsFusionInventoryAgents           Get-GlpiToolsFusionInventoryAgents
 Get-GlpiToolsGroups                          Get-GlpiToolsGroups
 Get-GlpiToolsItemLogs                        Get-GlpiToolsItemLogs
 Get-GlpiToolsListSearchOptions               Get-GlpiToolsListSearchOptions
 Get-GlpiToolsMonitors                        Get-GlpiToolsMonitors
 Get-GlpiToolsMyProfiles                      Get-GlpiToolsMyProfiles
 Get-GlpiToolsNetworkEquipments               Get-GlpiToolsNetworkEquipments
 Get-GlpiToolsPdus                            Get-GlpiToolsPdus
 Get-GlpiToolsPeripherals                     Get-GlpiToolsPeripherals
 Get-GlpiToolsPhones                          Get-GlpiToolsPhones
 Get-GlpiToolsPlugins                         Get-GlpiToolsPlugins
 Get-GlpiToolsPrinters                        Get-GlpiToolsPrinters
 Get-GlpiToolsProfiles                        Get-GlpiToolsProfiles
 Get-GlpiToolsRacks                           Get-GlpiToolsRacks
 Get-GlpiToolsSoftware                        Get-GlpiToolsSoftware
 Get-GlpiToolsSystemConfig                    Get-GlpiToolsSystemConfig
 Get-GlpiToolsUsers                           Get-GlpiToolsUsers
 Remove-GlpiToolsItems                        Remove-GlpiToolsItems
 Search-GlpiToolsItems                        Search-GlpiToolsItems
 Set-GlpiToolsChangeActiveEntities            Set-GlpiToolsChangeActiveEntities
 Set-GlpiToolsChangeActiveProfile             Set-GlpiToolsChangeActiveProfile
 Set-GlpiToolsConfig                          Set-GlpiToolsConfig
 Set-GlpiToolsInitSession                     Set-GlpiToolsInitSession
 Set-GlpiToolsKillSession                     Set-GlpiToolsKillSession
 Set-GlpiToolsPasswordReset                   Set-GlpiToolsPasswordReset
 Set-GlpiToolsResetPasswordRequest            Set-GlpiToolsResetPasswordRequest
 Update-GlpiToolsItems                        Update-GlpiToolsItems
 ```