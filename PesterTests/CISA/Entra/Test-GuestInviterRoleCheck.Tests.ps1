BeforeAll {
Write-TestInProgress
}

Describe "Test-GuestInviterRoleCheck" -Tag "CISA", "Entra", "Done" {
  Context "Only Administrators and users with Guest Inviter role Should be able to invite guests - MS.AAD.8.2" {
    It "Validates Guest Invite Settings" {
      $result = Test-GuestInviterRoleCheck
      $result | Should -Be "Pass" -Because "Only Administrators and users with Guest Inviter role Should be able to invite guests"
    }
  }
}
