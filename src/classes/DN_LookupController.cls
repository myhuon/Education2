/**
 * Created by 천유정 on 2022-08-17.
 */

public with sharing class DN_LookupController {

    @AuraEnabled
    public static List<SObject> querySalesforceRecord(String queryString) {
        System.debug('querySalesforceRecord');
        return Database.query(queryString);
    }

    @AuraEnabled
    public static Map<String, Object> getLookupDatas(String query, String sObjectName, String[] fieldSet, String searchKey, String viewObjectName, Id viewObjectId) {
        System.debug('query : ' + query);
        Map<String, Schema.SObjectField> mapFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();

        // Order Item Grid > Columns List
        List<Map<String, String>> listColumns = new List<Map<String, String>>();
        for(String field : fieldSet) {
            Schema.DescribeFieldResult describe = mapFields.get(field).getDescribe();
            if(describe.getName() == 'ProductGroup__c') continue;
            listColumns.add(new Map<String, String> {
                    'label' => describe.getLabel(),
                    'fieldName' => describe.getName(),
                    'type' => String.valueOf(describe.getType())
            });
        }

        List<Product2> listDatas = Database.query(query);
        System.debug('### listDatas : ' + listDatas);
        System.debug('### searchKey : \'' + searchKey + '\'');
        System.debug('### viewObjectName : ' + viewObjectName);

        Map<String, Object> mapReturnValue = new Map<String, Object>{ 'listColumns' => listColumns };

        try {
            if(''.equals(searchKey) || 'ALL'.equals(searchKey.toUpperCase())) {
                // 1. View Object 정보 조회 (Order or Opportunity)
                Id partnerAccountId;
                String partnerCurrency;
                String partnerDealType;

                if(viewObjectName == 'Order') {
                    Order objOrder = [SELECT Id, Partner__r.Id, Partner__r.CurrencyIsoCode, Partner__r.DEAL_TYPE__c FROM Order WHERE Id = :viewObjectId];
                    partnerAccountId = objOrder.Partner__r.Id;
                    partnerCurrency = objOrder.Partner__r.CurrencyIsoCode;
                    partnerDealType = objOrder.Partner__r.DEAL_TYPE__c;
                    System.debug('### objOrder : ' + objOrder);
                } else if(viewObjectName == 'Opportunity') {
                    Opportunity objOpportunity = [SELECT Id, Partner__r.Id, Partner__r.CurrencyIsoCode, Partner__r.DEAL_TYPE__c FROM Opportunity WHERE Id = :viewObjectId];
                    partnerAccountId = objOpportunity.Partner__r.Id;
                    partnerCurrency = objOpportunity.Partner__r.CurrencyIsoCode;
                    partnerDealType = objOpportunity.Partner__r.DEAL_TYPE__c;
                    System.debug('### objOpportunity : ' + objOpportunity);
                }
                System.debug('### partnerCurrency : ' + partnerCurrency);


                Set<String> setPE = new Set<String>();
                Set<String> setPBQ = new Set<String>();
                Set<String> setPBA = new Set<String>();
                for(Product2 obj : listDatas) {
                    setPE.add(obj.Id);
                    setPBQ.add(obj.ProductGroup__c);
                    if(obj.ProductGroup__c != null) setPBA.add(obj.ProductGroup__c.substring(0, 5));
                }

                // 2. PricebookEntry 조회
                List<PricebookEntry> listPE = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2.IsStandard = TRUE AND CurrencyIsoCode = :partnerCurrency AND Product2Id IN :setPE];
                Map<Id, PricebookEntry> mapPE = new Map<Id, PricebookEntry>();
                for(PricebookEntry obj : listPE) {
                    mapPE.put(obj.Product2Id, obj);
                }

                // 3. PricebookByQuantity__c 조회
                List<PricebookByQuantity__c> listPBQ = [SELECT Id, ProductGroup__c FROM PricebookByQuantity__c WHERE ProductGroup__c IN :setPBQ AND CurrencyIsoCode = :partnerCurrency AND DEAL_TYPE__c = :partnerDealType];
                Map<String, PricebookByQuantity__c> mapPBQ = new Map<String, PricebookByQuantity__c>();
                for(PricebookByQuantity__c obj : listPBQ) {
                    mapPBQ.put(obj.ProductGroup__c, obj);
                }

                // 4. PricebookByAccount__c 조회
                setPBA.add('*');
                List<PricebookByAccount__c> listPBA = [SELECT Id, ProductGroup__c FROM PricebookByAccount__c WHERE Account__c = :partnerAccountId AND ProductGroup__c IN :setPBA];
                Map<String, PricebookByAccount__c> mapPBA = new Map<String, PricebookByAccount__c>();
                for(PricebookByAccount__c obj : listPBA) {
                    mapPBA.put(obj.ProductGroup__c, obj);
                }

                // 5. Valid Check
                List<Product2> listPassedProduct = new List<Product2>();
                for(Product2 obj : listDatas) {
                    // 5-1. PricebookEntry
                    if(mapPE.get(obj.Id) == null) {
                        continue;
                    }

                    // 5-2. PricebookByQuantity__c
                    else if(mapPBQ.get(obj.ProductGroup__c) == null) {
                        continue;
                    }

                    // 5-3. PricebookByAccount__c
                    else if(mapPBA.get('*') == null && mapPBA.get(obj.ProductGroup__c) == null) {
                        continue;
                    }

                    System.debug('#### : ' + obj);
                    listPassedProduct.add(obj);
                }
                mapReturnValue.put('listDatas', listPassedProduct);
            }
        } catch(Exception e) {
            System.debug('#### ' + e.getMessage() + ' Line : ' + e.getLineNumber());
        }

        if(mapReturnValue.get('listDatas') == null) { mapReturnValue.put('listDatas', listDatas); }
        System.debug('mapReturnValue : ' + mapReturnValue);

        return mapReturnValue;
    }
}