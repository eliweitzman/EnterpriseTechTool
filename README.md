# 🚀 Eli's Enterprise Tech Toolkit!

[![GitHub License](https://img.shields.io/github/license/eliweitzman/Enterprisetechtool?style=flat&link=https%3A%2F%2Fgithub.com%2Feliweitzman%2FEnterpriseTechTool%2Fblob%2Fmain%2FLICENSE)](https://img.shields.io/github/license/eliweitzman/enterprisetechtool?link=https%3A%2F%2Fgithub.com%2Feliweitzman%2FEnterpriseTechTool%2Fblob%2Fmain%2FLICENSE
) [![GitHub all releases](https://img.shields.io/github/downloads/eliweitzman/enterprisetechtool/total)](https://github.com/eliweitzman/EnterpriseTechTool/releases) ![GitHub Repo stars](https://img.shields.io/github/stars/eliweitzman/enterprisetechtool) ![GitHub Discussions](https://img.shields.io/github/discussions/eliweitzman/enterprisetechtool?link=https%3A%2F%2Fgithub.com%2Feliweitzman%2FEnterpriseTechTool%2Fdiscussions)

Welcome to Eli's Enterprise Tech Tool (ETT, or Enterprise Tech Tool, for short). In this project, I hope to combine a bunch of useful sysadmin/helpdesk solutions that could be potentially helpful in general field work. ETT is an all-in-one power tool for Windows, built as a PowerShell script. Designed with IT professionals in mind, this application is customizable, and feature-packed with tons of admin tools to make life easier. Most of these projects are made from ideas I've had while at work, but hopefully some new functions come about soon!

## Features

<p align="center">
  <img src="https://github.com/eliweitzman/EnterpriseTechTool/blob/1.3-Dev/ImageAssets/ETTToolbox.png?raw=true" alt="A screenshot of the application window." width=60% height=60%/>
</p>

### Core Functions

- Clear Last Windows Session Login
- Retreive Microsoft and Windows LAPS passwords from On-Prem AD (Azure AD Windows LAPS now available!)
- Update all apps (using Windows Package Manager)
- Update Device Policy (gpupdate)
- System-aware dark/light mode!
- Retreive device information details
- Set hardware/software compliance flags
- Embed custom powershell scripts
- And more!

### Additional Modules!

- AD Explorer Pop-out! (Uses RSAT AD Tools)

<p align="center">
  <img src="https://github.com/eliweitzman/EnterpriseTechTool/blob/main/ImageAssets/ADExplorerSC.png" alt="A screenshot of an Active Directory Explorer popout function." width=50% height=50%/>
</p>

- LAPS Pop-out!

<p align="center">
  <img src="https://github.com/eliweitzman/EnterpriseTechTool/blob/main/ImageAssets/LAPSLightmodeSC.png" alt="A screenshot of a LAPS UI popout function to get LAPS passcodes." width=50% height=50%/>
</p>

_A standalone version of the LAPS client currently lives at [https://github.com/eliweitzman/ETT-LAPS](https://github.com/eliweitzman/ETT-LAPS) in case you don't want to download the whole toolkit! Version updates for this will be updated in sequence, but all changes will be made here in ETT._

## Recommended Experience before deployment

While it's optional, and I try to add as much context and instructions to the project as possible to run without experience, it would be good to have some experience in the following tools:

- PowerShell
- Windows PowerShell ISE
- Active Directory

## Runtime Options

ETT can run in a few different ways, depending on preference, and on your own personal security preferences.

| Run option | Details          |
| ------- | ------------------ |
| Stock PS Script | Just downloading and running the PS1 file direct from the repository. |
| Stock EXE Version | A pre-compiled stock version of ETT, either with Admin mode on or off. Able to bypass execution policy. |
| Modified PS Script | Downloading the PS1 file, and adjusting the feature flags (indicated below). |
| Modified EXE | Modifying the flags, and compiling it as an EXE for use. Able to bypass execution policy.|

## Install Methods

1. Using the Windows Package Manager (Machine-wide only... [info](https://github.com/eliweitzman/EnterpriseTechTool/wiki/Compiling-and-Runtime-How%E2%80%90To))

Standard Install:
```
winget install --id=EliWeitzman.ETT
```

2. Self-extracting Installer

Simply run the latest release's ETT.Installer.exe

3. Portable Mode

A single, standalone EXE application, portable enough to fit on a flash drive! 

## Automatic Updates

Beginning with release 1.2.1, ETT will now be able to automatically check for, and run software updates. However, there are a few key prerequisites necessary. 

1. Ensure the Windows Package Manager tool is installed (or that you have the latest version of the App Installer Windows App).
2. You must be running an installed version of ETT. Portable versions will prompt that an update is available to download, but it will not self-update.

## Optimal Environment

The application is designed to run as a PowerShell Script, but as well is compiled into an executable, using the awesome module [PS2EXE](https://github.com/MScholtes/PS2EXE), made by MScholtes, based on code by [Ingo Karstein](https://github.com/ikarstein/ps2exe). This is currently designed to run in an Enterprise environment, however it is tweakable to be run as a personal tool as well (although LAPS, policy updates, and a few other tools certainly aren't necessary).

## Customizing for your Deployment

In the first few lines of the program, there are a few sections that are commented out, allowing for color customization, as well as other customizations to compliance checking thresholds. These are customizable as needed, but the stock is as well provided, and disables any compliance checks. To understand what each flag does, check out this [Wiki](https://github.com/eliweitzman/EnterpriseTechTool/wiki/Customization-Overview) page for more!

```
#Admin mode - if auto-elevate is enabled, this will be set to $true. If in EXE mode, this is automatically handled by Windows.
$adminmode = $false

#Set Branding - CHANGE THIS TO MATCH YOUR PREFERENCE
$BrandColor = '#023a24' #Set the color of the form, currently populated with a hex value.
$LogoLocation = $null #If you want to use a custom logo, set the path here. Otherwise, leave as $null

#ETT UI Options
$backgroundImagePath = "" #Set this to a web URL or local path to change the BG image of ETT
$ettHeaderTextColor = [System.Drawing.Color]::FromName("White")#Override the color of the ETT header if a BG image is set. Otherwise, it will change based on system theme
$timeout = $false #Set this to $true to enable a timeout for ETT. Otherwise, set to $false
$timeoutLength = 300 #Set the length of the timeout in seconds. Default is 300 seconds (5 minutes)

#Compliance Thresholds - CHANGE THESE TO MATCH YOUR COMPLIANCE REQUIREMENTS
#RAM Check
$ramCheckActive = $false
$ramMinimum = 8 #SET MINIMUM RAM IN GB

#Drivespace Check
$drivespaceCheckActive = $false
$drivespaceMinimum = 20 #SET MINIMUM DRIVESPACE IN GB

#Windows Version Check
$winverCheckActive = $false
$winverTarget = '22h2' #SET TARGET WINDOWS VERSION (21h1, 21h2, 22h2)
```

## Contributing

ETT is an open-source application, and I'd love to make it open for contribution! If you would like to add a feature, or propose an idea to be added to the future, fill out a GitHub issue, and I'll start tinkering with it! Every enterprise and user is different, so a one-size-fits-all solution is almost impossible without input! Check out our [contributing page](https://github.com/eliweitzman/EnterpriseTechTool/blob/main/.github/CONTRIBUTING.md) to learn more about how to help build ETT for the future! Also, be sure to check out the [Code of Conduct](https://github.com/eliweitzman/EnterpriseTechTool/blob/main/.github/CODE_OF_CONDUCT.md) for our moderation practices.

## License

This code is provided under a [BSD-3-Clause License]( https://opensource.org/license/BSD-3-clause/ ). For a fun video understanding licenses, [this]( https://www.youtube.com/watch?v=Lj7i-azQaKk ) video wraps up upen source license types pretty cleanly!

## General Disclaimer
I'm currently a college student, and this project was a small timefiller. I might not be able to add new features or maintain this as quickly and consistently in the future. I hope by making this open-source, many others will choose to contribute and grow this application even further (although it certainly is challening, this being PowerShell-based and all). Plus, this is my first open-source project, and I'm pumped to learn more through this launch! Also, occasionally, you may find GenZ language used. But not too much 😎. Also, for those curious about the wallpaper used in screenshots, I got it from [here](https://www.wallpaperhub.app/wallpapers/7437) on Wallpaperhub!

Lastly, this PowerShell-based application, like anything envolving an elevated environment, has the potential to bypass execution policies when run as an executable. While it provides a certain level of convenience, it may also carry security risks if used without proper understanding or precautions. It should be used responsibly, with explicit authorization and compliance with all relevant corporate and legal guidelines. If this application is to be used in script form, modifications to the code may be required, and a valid signature would be needed to maintain security integrity. More guidelines are laid out in our security policy page, linked [here](https://github.com/eliweitzman/EnterpriseTechTool/blob/main/.github/SECURITY.md). 
