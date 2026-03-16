BeforeAll {
Write-TestInProgress
}

Describe "Test-MultiAdminDeviceWipe" -Tag "Custom", "Intune", "Devices", "BetaAPI" {
  Context "Multi Admin Access Policy Device Wipe" {
    It "Validates multiple Admins required to Wipe a device - Custom.Intune.Devices.1.03" {
      $result = Test-MultiAdminDeviceWipe
      $result | Should -Be "Pass" -Because "Multiple Admins Should be required to Wipe a device"
    }
  }
}
