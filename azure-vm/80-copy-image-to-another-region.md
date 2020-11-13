---
layout: page
---
# Copy Image to another region

    az image copy `
        --source-object-name 'img-demo-linux-ci-1' `
        --source-resource-group 'img-demo-rg' `
        --target-location 'eastus' `
        --target-resource-group 'img-demo-rg-1' `
        --target-name 'img-demo-linux-ci-1-east' `
        --cleanup