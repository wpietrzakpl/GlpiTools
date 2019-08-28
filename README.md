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
 Key                                              Value
 ---                                              -----
 Set-GlpiToolsConfig 	                            Set-GlpiToolsConfig 
 Get-GlpiToolsConfig	                            Get-GlpiToolsConfig
 Set-GlpiToolsInitSession	                        Set-GlpiToolsInitSession
 Set-GlpiToolsKillSession	                        Set-GlpiToolsKillSession
 Get-GlpiToolsComputers	                          Get-GlpiToolsComputers
 Get-GlpiToolsEntities	                          Get-GlpiToolsEntities
 Get-GlpiToolsUsers	                              Get-GlpiToolsUsers
 Get-GlpiToolsFusionInventoryAgents	                  Get-GlpiToolsFusionInventoryAgents
 Get-GlpiToolsDropdownsStatusesOfItems	              Get-GlpiToolsDropdownsStatusesOfItems
 Search-GlpiToolsItems	                              Search-GlpiToolsItems
 Get-GlpiToolsGroups	                                Get-GlpiToolsGroups
 Get-GlpiToolsDropdownsOSUpdateSources	              Get-GlpiToolsDropdownsOSUpdateSources
 Get-GlpiToolsDropdownsComputerModels	                Get-GlpiToolsDropdownsComputerModels
 Get-GlpiToolsListSearchOptions	                      Get-GlpiToolsListSearchOptions
 Set-GlpiToolsChangeActiveEntities	                  Set-GlpiToolsChangeActiveEntities
 Set-GlpiToolsResetPasswordRequest	                  Set-GlpiToolsResetPasswordRequest
 Set-GlpiToolsPasswordReset	                          Set-GlpiToolsPasswordReset
 Get-GlpiToolsMyProfiles	                            Get-GlpiToolsMyProfiles
 Get-GlpiToolsActiveProfile	                          Get-GlpiToolsActiveProfile
 Get-GlpiToolsPlugins	                                Get-GlpiToolsPlugins
 Get-GlpiToolsSoftware	                              Get-GlpiToolsSoftware 
 Get-GlpiToolsDropdownsSoftwareCategory	              Get-GlpiToolsDropdownsSoftwareCategory
 Set-GlpiToolsChangeActiveProfile	                    Set-GlpiToolsChangeActiveProfile
 Get-GlpiToolsProfiles	                              Get-GlpiToolsProfiles
 Add-GlpiToolsItems	                                  Add-GlpiToolsItems
 Update-GlpiToolsItems	                              Update-GlpiToolsItems
 Remove-GlpiToolsItems	                              Remove-GlpiToolsItems
 Get-GlpiToolsSystemConfig	                          Get-GlpiToolsSystemConfig
 Get-GlpiToolsDocuments	                              Get-GlpiToolsDocuments
 Get-GlpiToolsItemLogs	                              Get-GlpiToolsItemLogs
 Get-GlpiToolsAppsStructuresComponent	                Get-GlpiToolsAppsStructuresComponent
 Get-GlpiToolsAppsStructuresComponentTarget	          Get-GlpiToolsAppsStructuresComponentTarget
 Get-GlpiToolsAppsStructuresComponentType	            Get-GlpiToolsAppsStructuresComponentType
 Get-GlpiToolsAppsStructuresComponentState	          Get-GlpiToolsAppsStructuresComponentState
 Get-GlpiToolsAppsStructuresComponentTechnic	        Get-GlpiToolsAppsStructuresComponentTechnic
 Get-GlpiToolsAppsStructuresComponentUser	            Get-GlpiToolsAppsStructuresComponentUser
 Get-GlpiToolsAppsStructuresComponentSla	            Get-GlpiToolsAppsStructuresComponentSla
 Get-GlpiToolsAppsStructuresComponentDb	              Get-GlpiToolsAppsStructuresComponentDb
 Get-GlpiToolsAppsStructuresComponentInstance	        Get-GlpiToolsAppsStructuresComponentInstance
 Get-GlpiToolsAppsStructuresComponentLicense	        Get-GlpiToolsAppsStructuresComponentLicense
 Get-GlpiToolsMonitors	                              Get-GlpiToolsMonitors
 Get-GlpiToolsNetworkEquipments	                      Get-GlpiToolsNetworkEquipments
 Get-GlpiToolsPeripherals	                            Get-GlpiToolsPeripherals
 Get-GlpiToolsPrinters	                              Get-GlpiToolsPrinters
 Get-GlpiToolsCartridgeItems	                        Get-GlpiToolsCartridgeItems
 Get-GlpiToolsConsumableItems	                        Get-GlpiToolsConsumableItems
 Get-GlpiToolsPhones	                                Get-GlpiToolsPhones
 Get-GlpiToolsRacks	                                  Get-GlpiToolsRacks
 Get-GlpiToolsEnclosures	                            Get-GlpiToolsEnclosures
 Get-GlpiToolsPdus	                                  Get-GlpiToolsPdus
 Get-GlpiToolsTickets	                                Get-GlpiToolsTickets
 Get-GlpiToolsProblems	                              Get-GlpiToolsProblems
 Get-GlpiToolsChanges	                                Get-GlpiToolsChanges
 Get-GlpiToolsRecurrentTickets	                      Get-GlpiToolsRecurrentTickets
 Get-GlpiToolsDropdownsLocations            	        Get-GlpiToolsDropdownsLocations
 Get-GlpiToolsDropdownsDomains	                      Get-GlpiToolsDropdownsDomains
 Get-GlpiToolsDropdownsNetworks	                      Get-GlpiToolsDropdownsNetworks
 Get-GlpiToolsDropdownsComputerTypes	                Get-GlpiToolsDropdownsComputerTypes
 Get-GlpiToolsDropdownsManufacturers	                Get-GlpiToolsDropdownsManufacturers
 Get-GlpiToolsSoftwareVersions	                      Get-GlpiToolsSoftwareVersions
 Get-GlpiToolsComputerSoftwareVersions	              Get-GlpiToolsComputerSoftwareVersions
 Get-GlpiToolsDropdownsMonitorModels	                Get-GlpiToolsDropdownsMonitorModels
 Get-GlpiToolsFinancialAndAdministrativeInformations	Get-GlpiToolsFinancialAndAdministrativeInformations
 Get-GlpiToolsDropdownsBlacklists	                    Get-GlpiToolsDropdownsBlacklists
 Get-GlpiToolsDropdownsBlacklistedMailContent	        Get-GlpiToolsDropdownsBlacklistedMailContent
 Get-GlpiToolsDropdownsTicketCategories	              Get-GlpiToolsDropdownsTicketCategories
 Get-GlpiToolsDropdownsUserTitles	                    Get-GlpiToolsDropdownsUserTitles
 Get-GlpiToolsDropdownsUserCategories	                Get-GlpiToolsDropdownsUserCategories
 Get-GlpiToolsDropdownsOperatingSystems	              Get-GlpiToolsDropdownsOperatingSystems
 Get-GlpiToolsDropdownsOSVersions	                    Get-GlpiToolsDropdownsOSVersions
 Get-GlpiToolsDropdownsOSServicePacks	                Get-GlpiToolsDropdownsOSServicePacks
 Get-GlpiToolsDropdownsOSArchitectures	              Get-GlpiToolsDropdownsOSArchitectures
 Get-GlpiToolsDropdownsOSEditions	                    Get-GlpiToolsDropdownsOSEditions
 Get-GlpiToolsDropdownsOSKernels	                    Get-GlpiToolsDropdownsOSKernels
 Get-GlpiToolsDropdownsOSKernelVersions	              Get-GlpiToolsDropdownsOSKernelVersions
 ```