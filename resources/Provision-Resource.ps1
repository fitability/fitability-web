# Provisions resources based on Flags
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $ResourceGroupName = "",

    [string]
    [Parameter(Mandatory=$false)]
    $DeploymentName = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ResourceName = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ResourceShortName = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ResourceNameSuffix = "",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("", "koreacentral", "westus2")]
    $Location = "",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("", "krc", "wus2")]
    $LocationCode = "",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "test", "prod")]
    $Environment = "dev",

    ### Storage Account ###
    [bool]
    [Parameter(Mandatory=$false)]
    $ProvisionStorageAccount = $false,

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Standard_GRS", "Standard_LRS", "Standard_ZRS", "Standard_GZRS", "Standard_RAGRS", "Standard_RAGZRS", "Premium_LRS", "Premium_ZRS")]
    $StorageAccountSku = "Standard_LRS",

    [string[]]
    [Parameter(Mandatory=$false)]
    $StorageAccountBlobContainers = @( "webapp", "apiapp" ),
    ### Storage Account ###

    ### Log Analytics ###
    [bool]
    [Parameter(Mandatory=$false)]
    $ProvisionLogAnalyticsWorkspace = $false,

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Free", "Standard", "Premium", "Standalone", "LACluster", "PerGB2018", "PerNode", "CapacityReservation")]
    $LogAnalyticsWorkspaceSku = "PerGB2018",
    ### Log Analytics ###

    ### Application Insights ###
    [bool]
    [Parameter(Mandatory=$false)]
    $ProvisionAppInsights = $false,

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("web", "other")]
    $AppInsightsType = "web",

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("ApplicationInsights", "ApplicationInsightsWithDiagnosticSettings", "LogAnalytics")]
    $AppInsightsIngestionMode = "LogAnalytics",
    ### Application Insights ###

    ### Static Web App ###
    [bool]
    [Parameter(Mandatory=$false)]
    $ProvisionStaticWebApp = $false,

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Free", "Standard")]
    $StaticWebAppSkuName = "Free",

    [bool]
    [Parameter(Mandatory=$false)]
    $StaticWebAppAllowConfigFileUpdates = $true,

    [string]
    [Parameter(Mandatory=$false)]
    [ValidateSet("Disabled", "Enabled")]
    $StaticWebAppStagingEnvironmentPolicy = "Enabled",
    ### Static Web App ###

    [switch]
    [Parameter(Mandatory=$false)]
    $WhatIf,

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This provisions resources to Azure

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            -ResourceGroupName <resource group name> ``
            -DeploymentName <deployment name> ``
            -ResourceName <resource name> ``
            [-ResourceShortName <resource short name> ``
            [-ResourceNameSuffix <resource name suffix>] ``
            [-Location <location>] ``
            [-LocationCode <location code>] ``
            [-Environment <environment>] ``

            [-ProvisionStorageAccount <`$true|`$false>] ``
            [-StorageAccountSku <Storage Account SKU>] ``
            [-StorageAccountBlobContainers <Storage Account blob containers>] ``

            [-ProvisionLogAnalyticsWorkspace <`$true|`$false>] ``
            [-LogAnalyticsWorkspaceSku <Log Analytics workspace SKU>] ``

            [-ProvisionAppInsights <`$true|`$false>] ``
            [-AppInsightsType <Application Insights type>] ``
            [-AppInsightsIngestionMode <Application Insights data ingestion mode>] ``

            [-ProvisionStaticWebApp <`$true|`$false>] ``
            [-StaticWebAppSkuName <Static Web App SKU name>] ``
            [-StaticWebAppAllowConfigFileUpdates <`$true|`$false>>] ``
            [-StaticWebAppStagingEnvironmentPolicy <Static Web App staging envronment policy>] ``

            [-WhatIf] ``
            [-Help]

    Options:
        -ResourceGroupName                Resource group name.
        -DeploymentName                   Deployment name.
        -ResourceName                     Resource name.
        -ResourceShortName                Resource short name.
                                          Default is to use the resource name.
        -ResourceNameSuffix               Resource name suffix.
                                          Default is empty string.
        -Location                         Resource location.
                                          Default is empty string.
        -LocationCode                     location code.
                                          Default is empty string.
        -Environment                      environment.
                                          Default is 'dev'.

        -ProvisionStorageAccount          To provision Storage Account or not.
                                          Default is `$false.
        -StorageAccountSku                Storage Account SKU.
                                          Default is 'Standard_LRS'.
        -StorageAccountBlobContainers     Storage Account blob containers array.
                                          Default is 'webapp,apiapp'.

        -ProvisionLogAnalyticsWorkspace   To provision Log Analytics Workspace
                                          or not. Default is `$false.
        -LogAnalyticsWorkspaceSku         Log Analytics workspace SKU.
                                          Default is 'PerGB2018'.

        -ProvisionAppInsights             To provision Application Insights
                                          or not. Default is `$false.
        -AppInsightsType                  Application Insights type.
                                          Default is 'web'.
        -AppInsightsIngestionMode         Application Insights data ingestion
                                          mode. Default is 'ApplicationInsights'.

        -ProvisionStaticWebApp            To provision Static Web App or not.
                                          Default is `$false.
        -StaticWebAppSkuName              Static Web App SKU name.
                                          Default is 'Free'.
        -StaticWebAppAllowConfigFileUpdates
                                          To allow config file update or not.
                                          Default is `$true.
        -StaticWebAppStagingEnvironmentPolicy
                                          Staging environment policy.
                                          Default is 'Enabled'.

        -WhatIf:                          Show what would happen without
                                          actually provisioning resources.
        -Help:                            Show this message.
"

    Exit 0
}

# Show usage
$needHelp = ($ResourceGroupName -eq "") -or ($DeploymentName -eq "") -or ($ResourceName -eq "") -or ($Help -eq $true)
if ($needHelp -eq $true) {
    Show-Usage
    Exit 0
}

# Override resource short name with resource name if resource short name is not specified
if ($ResourceShortName -eq "") {
    $ResourceShortName = $ResourceName
}

# Force the dependencies to be provisioned - Application Insights
if ($ProvisionAppInsights -eq $true) {
    $ProvisionLogAnalyticsWorkspace = $true
}

# Force the dependencies to be provisioned - Static Web App
if ($ProvisionStaticWebApp -eq $true) {
    $ProvisionStorageAccount = $true
    $ProvisionAppInsights = $true
    $ProvisionLogAnalyticsWorkspace = $true
}

# Build parameters
$params = @{
    name = @{ value = $ResourceName };
    shortName = @{ value = $ResourceShortName };
    suffix = @{ value = $ResourceNameSuffix };
    location = @{ value = $Location };
    locationCode = @{ value = $LocationCode };
    env = @{ value = $Environment };

    storageAccountToProvision = @{ value = $ProvisionStorageAccount };
    storageAccountSku = @{ value = $StorageAccountSku };
    storageAccountBlobContainers = @{ value = $StorageAccountBlobContainers };

    workspaceToProvision = @{ value = $ProvisionLogAnalyticsWorkspace };
    workspaceSku = @{ value = $LogAnalyticsWorkspaceSku };

    appInsightsToProvision = @{ value = $ProvisionAppInsights };
    appInsightsType = @{ value = $AppInsightsType };
    appInsightsIngestionMode = @{ value = $AppInsightsIngestionMode };

    staticWebAppToProvision = @{ value = $ProvisionStaticWebApp };
    staticWebAppSkuName = @{ value = $StaticWebAppSkuName };
    staticWebAppAllowConfigFileUpdates = @{ value = $StaticWebAppAllowConfigFileUpdates };
    staticWebAppStagingEnvironmentPolicy = @{ value = $StaticWebAppStagingEnvironmentPolicy };
}

# Uncomment to debug
# $params | ConvertTo-Json
# $params | ConvertTo-Json -Compress
# $params | ConvertTo-Json -Compress | ConvertTo-Json

$stringified = $params | ConvertTo-Json -Compress | ConvertTo-Json

# Provision the resources
if ($WhatIf -eq $true) {
    Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Provisioning resources as a test ..."
    az deployment group create -g $ResourceGroupName -n $DeploymentName `
        -f ./azuredeploy.bicep `
        -p $stringified `
        -w

        # -u https://raw.githubusercontent.com/fitability/fitability-web/main/resources/azuredeploy.bicep `
} else {
    Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Provisioning resources ..."
    az deployment group create -g $ResourceGroupName -n $DeploymentName `
        -f ./azuredeploy.bicep `
        -p $stringified `
        --verbose

        # -u https://raw.githubusercontent.com/fitability/fitability-web/main/resources/azuredeploy.bicep `

    Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] Resources have been provisioned"
}
