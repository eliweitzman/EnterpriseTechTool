![Logo](https://github.com/eliweitzman/EnterpriseTechTool/blob/main/Eli's%20Enterprise.png)

Welcome to Eli's Enterprise Tech Tool (ETT, for short). In this project, I hope to combine a bunch of useful sysadmin/helpdesk solutions that could be potentially helpful in general field work. Most of these projects are made from ideas I've had while at work, but hopefully some new functions come about soon!

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
| Stock EXE Version | A pre-compiled stock version of ETT, either with Admin mode on or off. |
| Modified PS Script | Downloading the PS1 file, and adjusting the feature flags (indicated below). |
| Modified EXE | Modifying the flags, and compiling it as an EXE for use. |



## Optimal Environment

The application is designed to run as a PowerShell Script, but as well is compiled into an executable, using the awesome module PS2EXE, made by MScholtes (https://github.com/MScholtes/PS2EXE). This is currently designed to run in an Enterprise environment, however it is tweakable to be run as a personal tool as well (although LAPS, policy updates, and a few other tools certainly aren't necessary).

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

ETT is an open-source application, and I'd love to make it open for contribution! If you would like to add a feature, or propose an idea to be added to the future, fill out a GitHub issue, and I'll start tinkering with it! Every enterprise and user is different, so a one-size-fits-all solution is almost impossible without input!

## General Disclaimer
I'm currently a college student, and this project was a small timefiller. I might not be able to add new features or maintain this too much in the future. I hope by making this open-source, many others will choose to contribute and grow this application even further (although it certainly is challening, this being PowerShell-based an all). Also, occasionally, you may find GenZ language used. But not too much 😎
