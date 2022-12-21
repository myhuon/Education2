## Get Field Type

``` java

SObjectType r = ((SObject)(Type.forName('Schema.ObjectName').newInstance())).getSObjectType();
DescribeSObjectResult d = r.getDescribe();
System.debug('type : ' + d.fields.getMap()
                          .get('FieldName')
                          .getDescribe()
                          .getType());

```
