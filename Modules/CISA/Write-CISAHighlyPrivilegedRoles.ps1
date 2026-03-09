function Write-CISAHighlyPrivilegedRoles {
  [Cmdletbinding()]
  Param(
  )

<# 
  The following roles are considered Highly Privileged:
    Global Administrator            = 62e90394-69f5-4237-9190-012177145e10
    Privileged Role Administrator   = e8611ab8-c189-46e8-94e1-60213ab1f814
    User Administrator              = fe930be7-5e62-47db-91af-98c3a49a38b1
    SharePoint Administrator        = f28a1f50-f6e7-4571-818b-6a12f2af6b6c
    Exchange Administrator          = 29232cdf-9323-42fd-ade2-1d097af3e4de
    Hybrid Identity Administrator   = 8ac3fc64-6eca-42ea-9e69-59f4c7b60eb2
    Application Administrator       = 9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3
    Cloud Application Administrator = 158c047a-c907-4556-b7ef-446551a6b5f7
  https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference
#>

  $privilegedRoles = [ordered] @{
  'Global Administrator'            = "62e90394-69f5-4237-9190-012177145e10"
  'Privileged Role Administrator'   = "e8611ab8-c189-46e8-94e1-60213ab1f814"
  'User Administrator'              = "fe930be7-5e62-47db-91af-98c3a49a38b1"
  'SharePoint Administrator'        = "f28a1f50-f6e7-4571-818b-6a12f2af6b6c"
  'Exchange Administrator'          = "29232cdf-9323-42fd-ade2-1d097af3e4de"
  'Hybrid Identity Administrator'   = "8ac3fc64-6eca-42ea-9e69-59f4c7b60eb2"
  'Application Administrator'       = "9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3"
  'Cloud Application Administrator' = "158c047a-c907-4556-b7ef-446551a6b5f7"
  }

  Write-Output $privilegedRoles

}
