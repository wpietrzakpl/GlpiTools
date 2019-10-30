# GlpiTools
<div align="center">
<!-- Discord -->
  <a href="https://discord.gg/u4YdyVb">
    <img src="https://img.shields.io/discord/235574673155293194.svg?style=flat&label=Discord&logo=discord"
      alt="Discord - Chat" title="Discord - Chat" />
  </a>&nbsp;&nbsp;&nbsp;&nbsp;
  <!-- Slack -->
  <a href="https://join.slack.com/t/powershell-poland/shared_invite/enQtNDYxNjYzNjYwMjcyLTFmZGU1N2IyODY3ZDI0ZmJjYjM3OTYwMjkwYjQ5ZTU1MzM1ZTIwYjRmOGFhM2M3MjE1Zjk4NDY4MDRjNTBlOWQ">
    <img src="https://img.shields.io/badge/chat-on%20slack-orange.svg?style=flat&logo=slack"
      alt="Slack - Chat" title="Slack - Chat" />
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

 Or, Install from PowerShell Gallery
 ```
 Install-Module -Name GlpiTools 
 ```

 After those steps, you can start to use module

 ## Available commands

 ```
 Get-Module GlpiTools | Select-Object -ExpandProperty ExportedCommands
 ```