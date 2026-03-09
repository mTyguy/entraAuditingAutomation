BeforeAll {
Write-TestInProgress
}

Describe "Test-GuestsFromApprovedDomains" -Tag "CISA", "Entra" {
  Context "Guest Users should only originate from approved Domains - MS.AAD.8.3" {
    It "Validates Guest Invite Approved Domain Settings" {
      $result = Test-GuestsFromApprovedDomains
      $result | Should -Be "Pass" -Because "Guest Users should only originate from approved Domains"
    }
  }
}
