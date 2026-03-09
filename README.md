# entraAuditingAutomation
Entra/M365 auditing automation framework used to generate a baseline report of environment.

Demo:
[demo_2026-03-09.webm](https://github.com/user-attachments/assets/da171cfd-a25b-4f85-ade6-16b0ca75584d)

Features:
- Quickly assess an environment through API calls.
- Use tags (-Tags or -Skiptags when running Generate-Report.ps1) to curate which platform, feature, or benchmark to run tests against.
- Automatically creates HTML report describing Pass/Fail status, relevant live configuration in tenant, and guidance/documentation on how to harden.
- Custom function Get-AdminRoles that enumerates Users' assigned Administrator Roles via MgGraph -- can search by User principal name, user guid, role name, or role guid -- useful for on the fly enumeration of roles.

Current Rules:
- 43 rules scoped to CISA's baseline policies NIST 800-53 + FedRAMP High controls
- Assess Entra, Exchange, Defender, & Teams

Requirements: Microsoft Teams, ExchangeOnline, and MgGraph modules as well as Pester version 5 or greater and PSWriteHTML

Create your own modules by:
1) Creating the test .ps1 file and place in related Modules folder
2) Create Pester test in PesterTests
3) add .ps1 test in Modules.psm1

Inspired by CISA's SucbaGear tool and Maester.
