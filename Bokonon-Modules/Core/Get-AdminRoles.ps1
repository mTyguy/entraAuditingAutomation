function Get-AdminRoles {
  [Cmdletbinding()]
  Param(
    [string[]]$UPN,
    [string[]]$UserGuid,
    [string[]]$RoleName,
    [string[]]$RoleGuid
  )

  $userRoleLookup = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments?`$expand=principal").Value

  $userRoleArray = @()

  foreach ($_ in $userRoleLookup) {
    if ($_.principal.servicePrincipalType -ne "Application") {
      $userRoleArray += $loopresults = [ordered] @{
        'Display Name'        = $_.principal.displayName
        'User Principal Name' = $_.principal.userPrincipalName
        'User Guid'           = $_.principal.id
        'Role Guid'           = $_.roleDefinitionId
	'Role Display Name'   = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions/$($_.roleDefinitionId)").displayName
      }
    }
  }

# UPN or UserGuid set and RoleId is not set
  if ($UPN -ne $null -or $UserGuid -ne $null -and $RoleName -eq $null -and $RoleGuid -eq $null) {
    if ($UPN -ne $null) {
      $userResult = $userRoleArray | Where-Object {$_.'User Principal Name' -eq $UPN}
      $userResult
    } elseif ($UserGuid -ne $null) {
      $userGuidResult = $userRoleArray | Where-Object {$_.'User Guid' -eq $UserGuid}
      $userGuidResult
    }
  }

# Only Role Name
  if ($RoleName -ne $null) {
    $roleNameResult = $userRoleArray | Where-Object {$_.'Role Display Name' -eq $RoleName}
    $roleNameResult
  }

# Only RoleId is set
  if ($RoleGuid -ne $null) {
   $roleGuidResult = $userRoleArray | Where-Object {$_.'Role Guid' -eq $RoleGuid}
   $roleGuidResult 
  }
}
