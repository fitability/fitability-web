param name string
param suffix string = ''
param location string = resourceGroup().location
param locationCode string = 'wus2'

@allowed([
    'dev'
    'test'
    'prod'
])
param env string = 'dev'

param appInsightsId string
param appInsightsInstrumentationKey string

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

var metadata = {
    longName: '{0}-${name}{1}-${env}-${locationCode}'
    shortName: '{0}${name}{1}${env}${locationCode}'
}

var appInsights = {
    id: appInsightsId
    instrumentationKey: appInsightsInstrumentationKey
}
var staticApp = {
    name: suffix == '' ? format(metadata.longName, 'sttapp', '') : format(metadata.longName, 'sttapp', '-${suffix}')
    location: location
    skuName: staticWebAppSkuName
    allowConfigFileUpdates: staticWebAppAllowConfigFileUpdates
    stagingEnvironmentPolicy: staticWebAppStagingEnvironmentPolicy
}

resource sttapp 'Microsoft.Web/staticSites@2021-02-01' = {
    name: staticApp.name
    location: staticApp.location
    tags: {
        'hidden-link: /app-insights-resource-id': appInsights.id
        'hidden-link: /app-insights-instrmentation-key': appInsights.instrumentationKey
    }
    sku: {
        name: staticApp.skuName
    }
    properties: {
        allowConfigFileUpdates: staticApp.allowConfigFileUpdates
        stagingEnvironmentPolicy: staticApp.stagingEnvironmentPolicy
    }
}

output id string = sttapp.id
output name string = sttapp.name
