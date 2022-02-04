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
