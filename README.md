# entraAuditingAutomation
Entra/M365 auditing automation framework used to generate a baseline report of environment.

Features:
- Quickly assess an environment through API calls.
- Use tags (-Tags or -Skiptags when running Generate-Report.ps1) to curate which platform, feature, or benchmark to run tests against.
- Automatically creates HTML report describing Pass/Fail status, relevant live configuration in tenant, and guidance/documentation on how to harden.

Requirements: Microsoft Teams, ExchangeOnline, and MgGraph modules as well as Pester version 5 or greater and PSWriteHTML

Create your own modules by:
1) Creating the test .ps1 file and place in related Modules folder
2) Create Pester test in PesterTests
3) add .ps1 test in Modules.psm1

Inspired by CISA's SucbaGear tool and Maester.
