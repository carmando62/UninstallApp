Function GetApp ($appName) {
    #$ProductDetails = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "$appName*" } | Select Name, Version -ErrorAction SilentlyContinue
    $PDetails = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "$appName*" } -ErrorAction SilentlyContinue
    Return $PDetails
} # end of function

Function VerifyUninstall ($vAppName){
    Start-Sleep 1
    $Verify = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "$vAppName" } -ErrorAction SilentlyContinue
    If($null -eq $Verify){
            return 0
        } else {
            return 1
    }
}

Function UninstallApp ($UninstallAppName) {
    $UninstallDetails = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "$UninstallAppName" } -ErrorAction SilentlyContinue
    $uninst = $UninstallDetails.Uninstall()
    $process = (Start-Process -FilePath cmd.exe -ArgumentList '/c', $uninst -Passthru)
    $process.WaitForExit()
} # end of function

### Main Script
$appName = "Java"  # Example
$applications = GetApp $appName
Foreach ($app in $applications){
    # double check that the app is still installed.  Some applications Like Java uninstall other Java components such as the auto updater.
    Start-Sleep 1
    $checkapp = GetApp $app.Name
    If ( $null -ne $checkapp ) {
        $uninstallResults = $null
        $checkAppName = [string]$checkapp.Name
        Write-Host "Uninstalling $checkAppName" -ForegroundColor Yellow
        UninstallApp $checkAppName
        
        # check the results
        $verifyResults = VerifyUninstall $checkAppName
        If($verifyResults -eq 0){
            Write-Host "Uninstall Successfull." -ForegroundColor Green
        } else {
            Write-Error "Application did not uninstall correctly."
        }
    }
}
