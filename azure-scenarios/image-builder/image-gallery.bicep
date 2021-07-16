param galleryName string
param imageNames array
param location string = resourceGroup().location

resource gallery 'Microsoft.Compute/galleries@2020-09-30' = {
  name: galleryName
  location: location

  resource images 'images' = [for (item, index) in imageNames: {
    name: item
    location: location
    properties: {
      identifier: {
        offer: 'blah'
        publisher: 'blah'
        sku: 'blah'
      }
      osState: 'Generalized'
      osType: 'Windows'
    }
  }]
}

output galleryId string = gallery.id
output imageIds array = [for (item, index) in imageNames: gallery::images[index].id]
