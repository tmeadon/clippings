$appGwAddress = '<address>'

Invoke-RestMethod -Uri http://$appGwAddress/function01 -Body @{name = 'tom'}
Invoke-RestMethod -Uri http://$appGwAddress/function02 -Body @{name = 'tom'}
Invoke-RestMethod -Uri http://$appGwAddress/function03 -Body @{name = 'tom'}
Invoke-RestMethod -Uri http://$appGwAddress/function04 -Body @{name = 'tom'}