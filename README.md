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