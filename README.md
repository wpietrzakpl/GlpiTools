# GlpiTools

## Abstract

PowerShell Module which wrap Glpi API into handy functions.

***

## Prerequisites

 * Enable API - **You can do this here** - Setup -> General -> API -] Enable Rest API
 * Get URL of the API - **You can do this here** - Setup -> General -> API -] URL of the API (Copy URL and save for later use)
 * Configure Access From Localhost - **You can do this here** - Setup -> General -> API -> full access from localhost -] Filter access (I prefere to leave parameters, IPv4, IPv6 blank)
 * Get app_token - **You can do this here** - Setup -> General -> API -> full access from localhost -] Filter access (parameter Application token(app_token), click regenerate checkbox and save, after that app_token will show. Copy token and save it for later use)
 * Get User API token - **You can do this here** - Administration -> Users - (user) -> Settings -] Remote access keys (parameter API token, click regenerate checkbox and save, after that User Token will show. Copy token and save it for later use) - ! Remember that user must have permissions to do what u want to do with API

 ## Instalation

 To install\import module you have to:
 
 * Download module from GitHub (When finish module, will be to download from PowerShell Gallery)
 * Unzip module, remove GitHub branch name from the name of directory, and copy into folder which you have configured to store modules, you can find the path running command in PowerShell ``` $env:PSModulePath -split ";" ```
 * To import module into active powershell session you have to use command ` Import-Module GlpiTools `
 * Or if you want to install module you have to use command ` Install-Module GlpiTools `
 * Configure Module to later use with command `Set-GlpiToolsConfig`, pass to the command tokens and url which you have from Prerequisites section

 After those steps, you can start to use module

 ## Available commands

 ```
 Key                                   Value
 ---                                   -----
 Get-GlpiToolsComputers                Get-GlpiToolsComputers
 Get-GlpiToolsConfig                   Get-GlpiToolsConfig
 Get-GlpiToolsDropdownsComputerModels  Get-GlpiToolsDropdownsComputerModels
 Get-GlpiToolsDropdownsStatusesOfItems Get-GlpiToolsDropdownsStatusesOfItems
 Get-GlpiToolsDropdownsUpdateSources   Get-GlpiToolsDropdownsUpdateSources
 Get-GlpiToolsEntities                 Get-GlpiToolsEntities
 Get-GlpiToolsFusionInventoryAgents    Get-GlpiToolsFusionInventoryAgents
 Get-GlpiToolsGroups                   Get-GlpiToolsGroups
 Get-GlpiToolsListSearchOptions        Get-GlpiToolsListSearchOptions
 Get-GlpiToolsUsers                    Get-GlpiToolsUsers
 Search-GlpiToolsItems                 Search-GlpiToolsItems
 Set-GlpiToolsConfig                   Set-GlpiToolsConfig
 Set-GlpiToolsInitSession              Set-GlpiToolsInitSession
 Set-GlpiToolsKillSession              Set-GlpiToolsKillSession
 ```