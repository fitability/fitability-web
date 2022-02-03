param name string
param location string = resourceGroup().location
param locationCode string = 'wus2'
@allowed([
    'dev'
    'test'
    'prod'
])
param env string = 'dev'

param staticAppToProvision bool = false
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

module sttapp './staticWebApp.bicep' = if (staticAppToProvision) {
    name: 'StaticWebApp'
    params: {
        name: name
        location: location
        locationCode: locationCode
        env: env
        staticAppSkuName: staticAppSkuName
        staticAppAllowConfigFileUpdates: staticAppAllowConfigFileUpdates
        staticAppStagingEnvironmentPolicy: staticAppStagingEnvironmentPolicy
    }
}
