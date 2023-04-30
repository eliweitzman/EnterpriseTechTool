![Logo](https://github.com/eliweitzman/EnterpriseTechTool/blob/main/Eli's%20Enterprise.png)

Welcoem to Eli's Enterprise Tech Tool (ETT, for short lol). In this project, I hope to combine a bunch of useful sysadmin/helpdesk solutions that could be potentially helpful in general field work. Most of these projects are made from ideas I've had while at work, but hopefully some new functions come about soon!

## Recommended Experience before deployment

While it's optional, and I try to add as much context and instructions to the project as possible to run without experience, it would be good to have some experience in the following tools:

- PowerShell
- Active Directory

## Optimal Environment

The application is designed to run as a PowerShell Script, but as well is compiled into an executable, using the awesome module PS2EXE, made by MScholtes (https://github.com/MScholtes/PS2EXE). This is currently designed to run in an Enterprise environment, however it is tweakable to be run as a personal tool as well (although LAPS, policy updates, and a few other tools certainly aren't necessary).

## Customizing for your Deployment

In the first few lines of the program, there are a few sections that are commented out, allowing for color customization, as well as other customizations to compliance checking thresholds. These are customizable as needed, but the stock is as well provided, and disables any compliance checks.

## General Disclaimer
I'm currently a college student, and this project was a small timefiller. I might not be able to add new features or maintain this too much in the future. I hope by making this open-source, many others will choose to contribute and grow this application even further (although it certainly is challening, this being PowerShell-based an all). Also, occasionally, you may find GenZ language used. But not too much 😎
