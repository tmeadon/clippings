targetScope = 'subscription'

param baseName string = 'image-builder-test'
param location string = 'uksouth'
param destroyTime string = '18:00'

var imageNames = [
  '${baseName}-1'
]

resource rg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: baseName
  location: location
  tags: {
    DestroyTime: destroyTime
  }
}

module gallery 'image-gallery.bicep' = {
  scope: rg
  name: 'gallery'
  params: {
    galleryName: 'gallery'
    imageNames: imageNames
  }
}

module identity 'identity.bicep' = {
  scope: rg
  name: 'identity'
  params: {
    galleryId: gallery.outputs.galleryId
    msiName: baseName
  }
}

module imageTemplate 'image-template.bicep' = {
  scope: rg
  name: 'imageTemplate'
  params: {
    imageName: imageNames[0]
    galleryImageId: gallery.outputs.imageIds[0]
    msiId: identity.outputs.msiId
  }
}
