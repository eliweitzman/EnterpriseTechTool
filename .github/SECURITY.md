# Security Policy

This Security Policy provides guidelines and procedures for maintaining the confidentiality, integrity, and availability of the application hosted on this GitHub repository. It applies to all contributors and users of this repository. This application is written in PowerShell and can be run as a PowerShell script or compiled as an executable.

## Supported Versions

Due to the nature of the application being effectively just a PowerShell script, releases are only supported in active development. Should a security issue arise on your current version, patches only roll on newer updates, and there is no backwards support cycle currently in place. Users are expected to use the most recent version of the application for the best security and feature set. However, there is as well NO built-in update path yet.

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |

## ETT-Admin Version Support

With the latest updates in version 1.2.1, ETT-Admin's functions have been merged and segmented into ETT through "Run-As" elevation. As such, ETT-Admin is being further deprecated, and will no longer be updated or supported. However, ETT's latest release includes the same functionality, just as a combined version.

## User Assumptions

Users of ETT must ensure their local device's security measures are adequate. This includes ensuring they have an up-to-date operating system, antivirus software, and PowerShell version if they intend to run the application as a script.

## Contributions

All contributions must go through a code review process. Pull requests should be small and manageable. This process will ensure that no potentially harmful or unnecessary code is added to the repository. The repository maintainers have the right to reject any contribution that does not meet the required standards.

## Execution Policy Considerations

Running PowerShell scripts on a machine can pose a security risk if not handled correctly. Before running any script, ensure your PowerShell execution policy is set to an appropriate level. Avoid using "Unrestricted" as it allows all scripts to run, regardless of their source.

This application has no signature affixed, nor any current security certificate structure. You will need to apply a signature to this script and set your device execution policy as “RemoteSigned” or “AllSigned.”  If you are unsure about your execution policy settings, consult your system administrator or refer to [Microsoft's documentation]( https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.3).

This application should only be downloaded directly from this repository to ensure its authenticity. Do not run the script if it has been obtained from an untrusted source.

## Reporting a Vulnerability

If you encounter a security concern of extreme range, please get in touch with myself directly, or the maintainers, by drafting a new Security advisory. Depending on the security issue however, this could be due to a vulnerability in PowerShell, or Windows as a whole. 

Because there isn't a set development routine in place yet, nor full-time development determined, security concerns will be evaluated and addressed whenever a development cycle is started. 

Only create an issue on this repository if you are sure that the contained information cannot be used to compromise any systems that use ETT.

## Security Affirmation

Our goal is to continuously evaluate and improve our security measures. Any changes to this policy will be communicated to all users and contributors.

By using or contributing to this repository, you agree to adhere to this security policy.
