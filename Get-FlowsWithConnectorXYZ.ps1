# Tomislav Karafilov 29.11.2020
# Find Flows containing a Twitter connection

# Admin neccessary
#Install-Module -Name Microsoft.PowerApps.Administration.PowerShell  
#Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber  
#Install-Module -Name AzureAD

# Import needed stuff
Import-Module Microsoft.PowerApps.Administration.PowerShell -DisableNameChecking # Without DisableNameChecking I get a verb warning
Import-Module Microsoft.PowerApps.PowerShell
Import-Module AzureAD

# Get credentials by dialog
#$cred = Get-Credential

# Get credentials hard coded
$username = "<UserName>"
$password = ConvertTo-SecureString "<Password>" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)

# Initialize PowerApps
Add-PowerAppsAccount -Username $cred.UserName -Password $cred.Password

# Initialize Azure
Connect-AzureAD -Credential $cred | Out-Null

# Get all flows
$flows = Get-AdminFlow

# Get all flows vom default environment
#$flows = Get-AdminFlow -EnvironmentName (Get-FlowEnvironment -Default).EnvironmentName

# Results
$flowsFound = @()
$AllFlows = @()

Write-Host "Found $($flows.Count) Flow(s) total"

foreach ($flow in $flows) {
    # First element is an empty value element, so skip this
    if ($flow | Get-Member -Name "value"){
        continue}

    $detail = $flow | Get-AdminFlow
    #$detail.Internal.properties.connectionReferences	# connector infomation

    foreach($connection in $detail.Internal.properties.connectionReferences)
    {
        # The connection names can be found with "Get-PowerAppConnector | Out-GridView"
        # The connector name is found as member, so we have to check the members!
        $connectorFound = $connection | Get-Member -Name "shared_twitter"
        #$connectorFound = $connection | Get-Member -Name "shared_sql"
        #$connectorFound = $connection | Get-Member -Name "shared_sharepointonline"

        # Infos about a flow
        #Write-Host "Flow: ""$($flow.DisplayName)"" in ENV: ""$((Get-FlowEnvironment -EnvironmentName $flow.EnvironmentName | Select DisplayName).DisplayName)"" $($detail.Internal.properties.connectionReferences)"

        $AllFlows += [PSCustomObject]@{
            FlowName = $flow.FlowName;
            EnvironmentDisplayName = (Get-FlowEnvironment -EnvironmentName $flow.EnvironmentName | Select DisplayName).DisplayName;
            AllConnectionReferences = $detail.Internal.properties.connectionReferences;
        }

        if ($connectorFound)
        {
            # Connector found, collect informations
            $flowFound = [PSCustomObject]@{
                FlowName = $flow.FlowName;
                FlowDisplayName = $flow.DisplayName;
                FlowEnabled = $flow.Enabled;
                FlowCreatedByDisplayName = (Get-AzureADUser -ObjectId $flow.CreatedBy.userId).DisplayName
                FlowCreatedTime = $flow.CreatedTime;
                FlowLastModifiedTime = $flow.LastModifiedTime;
                FlowEnvironmentName = $flow.EnvironmentName
                FlowEnvironmentDisplayName = (Get-FlowEnvironment -EnvironmentName $flow.EnvironmentName | Select DisplayName);
                ConnectionDisplayName = $connection.shared_twitter.displayName;
                #ConnectionDisplayName = $connection.shared_sql.displayName;
                #ConnectionDisplayName = $connection.shared_sharepointonline.displayName;
                AllConnectionReferences = $detail.Internal.properties.connectionReferences;
            }

            #Disable-AdminFlow -EnvironmentName $flow.EnvironmentName -FlowName $flow.FlowName

            Write-Host "Flow with Twitter: ""$($flowFound.FlowDisplayName)"" in ENV: ""$($flowFound.FlowEnvironmentDisplayName.DisplayName)"""
            #Write-Host "Flow with SQL: ""$($flowFound.FlowDisplayName)"" in ENV: ""$($flowFound.FlowEnvironmentDisplayName.DisplayName)"""
            #Write-Host "Flow with SharePoint: ""$($flowFound.FlowDisplayName)"" in ENV: ""$($flowFound.FlowEnvironmentDisplayName.DisplayName)"""

            $flowsFound += $flowFound
        }
    }    
}

Write-Host "Found $($flowsFound.Count) Flow(s) matching"

$AllFlows | Out-GridView
$flowsFound | Out-GridView