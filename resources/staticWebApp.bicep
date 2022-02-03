param name string
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
param staticAppSkuName string = 'Free'

param staticAppAllowConfigFileUpdates bool = true

@allowed([
    'Disabled'
    'Enabled'
])
param staticAppStagingEnvironmentPolicy string = 'Enabled'

var metadata = {
    longName: '{0}-${name}-${env}-${locationCode}'
    shortName: '{0}${name}${env}${locationCode}'
}

var staticApp = {
    name: format(metadata.longName, 'sttapp')
    location: location
    skuName: staticAppSkuName
    allowConfigFileUpdates: staticAppAllowConfigFileUpdates
    stagingEnvironmentPolicy: staticAppStagingEnvironmentPolicy
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
