BeforeAll {
Write-TestInProgress
}

Describe "Test-MultiAdminDeviceDelete" -Tag "Custom", "Intune", "Devices", "BetaAPI" {
  Context "Multi Admin Access Policy Device Delete" {
    It "Validates multiple Admins required to Delete a device - Custom.Intune.Devices.1.01" {
      $result = Test-MultiAdminDeviceDelete
      $result | Should -Be "Pass" -Because "Multiple Admins Should be required to Delete a device"
    }
  }
}
