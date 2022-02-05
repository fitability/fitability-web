param name string
param shortName string = ''
param suffix string = ''
param location string = ''
param locationCode string = ''
@allowed([
    'dev'
    'test'
    'prod'
])
param env string = 'dev'

// Storage
param storageAccountToProvision bool = false
@allowed([
    'Standard_LRS'
    'Standard_ZRS'    
    'Standard_GRS'
    'Standard_GZRS'
    'Standard_RAGRS'
    'Standard_RAGZRS'
    'Premium_LRS'
    'Premium_ZRS'
])
param storageAccountSku string = 'Standard_LRS'
param storageAccountBlobContainers array = [
    'webapp'
    'apiapp'
]

// Log Analytics Workspace
param workspaceToProvision bool = false
@allowed([
    'Free'
    'Standard'
    'Premium'
    'Standalone'
    'LACluster'
    'PerGB2018'
    'PerNode'
    'CapacityReservation'
])
param workspaceSku string = 'PerGB2018'

// Application Insights
param appInsightsToProvision bool = false
@allowed([
    'web'
    'other'
])
param appInsightsType string = 'web'

@allowed([
    'ApplicationInsights'
    'ApplicationInsightsWithDiagnosticSettings'
    'LogAnalytics'
])
param appInsightsIngestionMode string = 'LogAnalytics'

// Static Web App
param staticWebAppToProvision bool = false
@allowed([
    'Free'
    'Standard'
])
param staticWebAppSkuName string = 'Free'
param staticWebAppAllowConfigFileUpdates bool = true
@allowed([
    'Disabled'
    'Enabled'
])
param staticWebAppStagingEnvironmentPolicy string = 'Enabled'

var locationResolved = location == '' ? resourceGroup().location : location
var locationCodeMap = {
    koreacentral: 'krc'
    'Korea Central': 'krc'
    westus2: 'wus2'
    'West US 2': 'wus2'
}
var locationCodeResolved = locationCode == '' ? locationCodeMap[locationResolved] : locationCode

module st './storageAccount.bicep' = if (storageAccountToProvision) {
    name: 'StorageAccount'
    params: {
        name: shortName
        suffix: suffix
        location: locationResolved
        locationCode: locationCodeResolved
        env: env
        storageAccountSku: storageAccountSku
        storageAccountBlobContainers: storageAccountBlobContainers
    }
}

module wrkspc './logAnalyticsWorkspace.bicep' = if (workspaceToProvision) {
    name: 'LogAnalyticsWorkspace'
    params: {
        name: name
        suffix: suffix
        location: locationResolved
        locationCode: locationCodeResolved
        env: env
        workspaceSku: workspaceSku
    }
}

module appins './appInsights.bicep' = if (appInsightsToProvision) {
    name: 'ApplicationInsights'
    params: {
        name: name
        suffix: suffix
        location: locationResolved
        locationCode: locationCodeResolved
        env: env
        appInsightsType: appInsightsType
        appInsightsIngestionMode: appInsightsIngestionMode
        workspaceId: wrkspc.outputs.id
    }
}

module sttapp './staticWebApp.bicep' = if (staticWebAppToProvision) {
    name: 'StaticWebApp'
    params: {
        name: name
        suffix: suffix
        location: locationResolved
        locationCode: locationCodeResolved
        env: env
        appInsightsId: appins.outputs.id
        appInsightsInstrumentationKey: appins.outputs.instrumentationKey
        staticWebAppSkuName: staticWebAppSkuName
        staticWebAppAllowConfigFileUpdates: staticWebAppAllowConfigFileUpdates
        staticWebAppStagingEnvironmentPolicy: staticWebAppStagingEnvironmentPolicy
    }
}
