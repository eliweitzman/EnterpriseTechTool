# 🚀 Eli's Enterprise Tech Toolkit!

Welcome to Eli's Enterprise Tech Tool (ETT, or Enterprise Tech Tool, for short). In this project, I hope to combine a bunch of useful sysadmin/helpdesk solutions that could be potentially helpful in general field work. ETT is an all-in-one power tool for Windows, built as a PowerShell script. Designed with IT professionals in mind, this application is customizable, and feature-packed with tons of admin tools to make life easier. Most of these projects are made from ideas I've had while at work, but hopefully some new functions come about soon!

## Features

<p align="center">
  <img src="https://github.com/eliweitzman/EnterpriseTechTool/blob/main/ImageAssets/UI%20Screenshot.png" alt="A screenshot of the application window." width=50% height=50%/>
</p>

### Core Functions

- Clear Last Windows Session Login
- Retreive Microsoft and Windows LAPS passwords from On-Prem AD (Azure AD Windows LAPS coming soon!)
- Update all apps (using Windows Package Manager)
- Update Device Policy (gpupdate)
- System-aware dark/light mode!
- Retreive device information details
- Set hardware/software compliance flags
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


## Optimal Environment

The application is designed to run as a PowerShell Script, but as well is compiled into an executable, using the awesome module [PS2EXE](https://github.com/MScholtes/PS2EXE), made by MScholtes, based on code by [Ingo Karstein](https://github.com/ikarstein/ps2exe). This is currently designed to run in an Enterprise environment, however it is tweakable to be run as a personal tool as well (although LAPS, policy updates, and a few other tools certainly aren't necessary).

## Customizing for your Deployment

In the first few lines of the program, there are a few sections that are commented out, allowing for color customization, as well as other customizations to compliance checking thresholds. These are customizable as needed, but the stock is as well provided, and disables any compliance checks.

```
#Admin mode - if auto-elevate is enabled, this will be set to $true
$adminmode = $false

#Set Branding - CHANGE THIS TO MATCH YOUR PREFERENCE
$BrandColor = '#023a24' #Set the color of the form, currently populated with a hex value.
$LogoLocation = $null #If you want to use a custom logo, set the path here. Otherwise, leave as $null

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

This code is provided under a [BSD-3-Clause License]( https://opensource.org/license/BSD-3-clause/ ). For a fun video understanding licenses, [this]( https://www.youtube.com/watch?v=Lj7i-azQaKk ) video wraps up license understanding pretty cleanly!

## General Disclaimer
I'm currently a college student, and this project was a small timefiller. I might not be able to add new features or maintain this as quickly and consistently in the future. I hope by making this open-source, many others will choose to contribute and grow this application even further (although it certainly is challening, this being PowerShell-based and all). Also, occasionally, you may find GenZ language used. But not too much 😎
