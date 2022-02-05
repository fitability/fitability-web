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

var metadata = {
    longName: '{0}-${name}{1}-${env}-${locationCode}'
    shortName: '{0}${name}{1}${env}${locationCode}'
}

var storage = {
    name: suffix == '' ? format(metadata.shortName, 'st', '') : format(metadata.shortName, 'st', suffix)
    location: location
    sku: storageAccountSku
    blob: {
        containers: storageAccountBlobContainers
    }
}

resource st 'Microsoft.Storage/storageAccounts@2021-06-01' = {
    name: storage.name
    location: storage.location
    kind: 'StorageV2'
    sku: {
        name: storage.sku
    }
    properties: {
        supportsHttpsTrafficOnly: true
    }
}

resource stblob 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
    name: '${st.name}/default'
    properties: {
        deleteRetentionPolicy: {
            enabled: false
        }
    }
}

resource stblobcontainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = [for container in storage.blob.containers: {
    name: '${stblob.name}/${container}'
    properties: {
        immutableStorageWithVersioning: {
            enabled: false
        }
        defaultEncryptionScope: '$account-encryption-key'
        denyEncryptionScopeOverride: false
        publicAccess: 'None'
    }
}]

output id string = st.id
output name string = st.name
