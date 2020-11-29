# Tomislav Karafilov 29.11.2020
# Find PowerApps containing a Twitter connection

# Admin neccessary
#Install-Module -Name Microsoft.PowerApps.Administration.PowerShell  
#Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber  

# Import needed stuff
Import-Module Microsoft.PowerApps.Administration.PowerShell -DisableNameChecking # Without DisableNameChecking I get a verb warning
Import-Module Microsoft.PowerApps.PowerShell

# Get credentials by dialog
#$cred = Get-Credential

# Get credentials hard coded
$username = "<UserName>"
$password = ConvertTo-SecureString "<Password>" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)

# Initialize PowerApps
Add-PowerAppsAccount -Username $cred.UserName -Password $cred.Password

$powerApps = Get-AdminPowerApp
$powerAppsFound = @()
$AllPowerApps = @()

Write-Host "Found $($powerApps.Count) PowerApp(s) total"

foreach($powerApp in $powerApps)
{
    $AllPowerApps += [PSCustomObject]@{
            PowerAppName = $powerApp.DisplayName;
                IsFeaturesApp = $powerApp.IsFeaturedApp;
                IsHeroApp = $powerApp.IsHeroApp;
                OwnerName = $powerApp.Owner.displayName;
                CreatedTime = $powerApp.CreatedTime;
                LastModifiedTime = $powerApp.LastModifiedTime;
                EnvironmentName = $powerApp.EnvironmentName;
                EnvironmentDisplayName = (Get-FlowEnvironment -EnvironmentName $powerApp.EnvironmentName | Select DisplayName);
        }

   if (Get-AdminPowerAppConnectionReferences -EnvironmentName $powerApp.EnvironmentName -AppName $powerApp.AppName | Where-Object -Property ConnectorName -EQ -Value "shared_twitter")
   #if (Get-AdminPowerAppConnectionReferences -EnvironmentName $powerApp.EnvironmentName -AppName $powerApp.AppName | Where-Object -Property ConnectorName -EQ -Value "shared_sql")
   #if (Get-AdminPowerAppConnectionReferences -EnvironmentName $powerApp.EnvironmentName -AppName $powerApp.AppName | Where-Object -Property ConnectorName -EQ -Value "shared_sharepointonline")
   {
        #$_ | Select-Object DisplayName, @{Label="Owner";e={$_.Owner.displayName}},@{Label="Email";e={$_.Owner.userPrincipalName}}, AppName 
        $powerAppFound = [PSCustomObject]@{
                PowerAppName = $powerApp.DisplayName;
                IsFeaturesApp = $powerApp.IsFeaturedApp;
                IsHeroApp = $powerApp.IsHeroApp;
                OwnerName = $powerApp.Owner.displayName;
                CreatedTime = $powerApp.CreatedTime;
                LastModifiedTime = $powerApp.LastModifiedTime;
                EnvironmentName = $powerApp.EnvironmentName;
                EnvironmentDisplayName = (Get-FlowEnvironment -EnvironmentName $powerApp.EnvironmentName | Select DisplayName);
            }

         Write-Host "PowerApp with Twitter: ""$($powerAppFound.PowerAppName)"" in ENV: ""$($powerAppFound.EnvironmentDisplayName.DisplayName)"""
 
         $powerAppsFound += $powerAppFound
   } 
}

Write-Host "Found $($powerAppsFound.Count) PowerApp(s) matching"

$powerAppsFound | Out-GridView
$AllPowerApps | Out-GridView