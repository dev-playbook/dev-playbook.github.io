{% if include.sku == 'F1' %}
    > F1 SKU (Stock Keeping Unit) is the FREE pricing tier. It has the following limitations.
    > - _Shares virtual machines_ with web apps from other accounts.
    > - _No deployment slots_ for a staging environment.
    > - _No custom domains_ so only {appname}.azurewebsite.net is possible.
    > - _No scaling out_ to multiple instances to allow load balancing.
{% endif %}

{% if include.sku == 'B1' %}
    >B1 SKU (Stock Keeping Unit) is part of the Basic pricing tier and is **chargeable**. It is production-grade with the following features and limitations
    > - Uses _dedicated virtual machines_ allowing scaling out to multiple instances.
    > - Allows for _customised domains_ and the use of _ssl certificates_
    > - Limited to _manual scaling_.
    > - _No deployment slots_ for staging environments.
{% endif %}

{% if include.sku == 'S1' %}
    > S1 SKU (Stock Keeping Unit) is part of the Standard pricing tier and is **chargeable**. It is production-grade with the following features.
    > - Uses _dedicated virtual machines_ allowing scaling out to multiple instances.
    > - Allows for _customised domains_ and the use of _ssl certificates_
    > - _Deployment slots_ for up to 5 environments.
    > - _Traffic Manager_ to control request distribution.
    > - _Auto-scale_ up to 10 instances.
{% endif %}
