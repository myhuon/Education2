/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-12
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-12   hyunsoo.song@daeunextier.com   Initial Version
 */
public with sharing class Evaluation2Controller {
    // 기회의 모든 제품들 반환
    private static List<OpportunityLineItem> getOpportunityLineItems (String recordId){
        List<OpportunityLineItem> listOpportunityLineItems = [
                SELECT Name, Product2Id, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id
                FROM OpportunityLineItem
                WHERE OpportunityId =: recordId
        ];

        return listOpportunityLineItems;
    }

    // 하나의 기회 제품 반환
    private static OpportunityLineItem getOpportunityLineItem (String itemId){
        List<OpportunityLineItem> listOpportunityLineItems = [
                SELECT Name, Product2Id, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id
                FROM OpportunityLineItem
                WHERE Id =: itemId
                LIMIT 1
        ];

        return listOpportunityLineItems[0];
    }

    @AuraEnabled
    public static List<OpportunityLineItem> getInitData(String recordId) {
        List<OpportunityLineItem> listOpportunityLineItems = getOpportunityLineItems(recordId);

        System.debug('[getInitData] recordId : ' + recordId);
        System.debug('[getInitData] listOpp : ' + listOpportunityLineItems);

        return listOpportunityLineItems;
    }

    /*@AuraEnabled
    public static boolean saveRecord(List<OpportunityLineItem> draftValues){
        System.debug('&&&&&&&&&&&&&&&&&& controller draftValues : ' + draftValues);
        try {
            //upsert draftValues;
            List<Database.upsertResult> results = Database.upsert(draftValues, false);
            System.debug('################### results : ' + results);
            return true;
        } catch(Exception e) {
            return false;
        }
    }*/

    @AuraEnabled
    public static boolean saveRecord(Map<String, OpportunityLineItem> draftValues){
        System.debug('&&&&&&&&&&&&&&&&&& controller draftValues : ' + draftValues);

        List<Opportunity> objOpp = [
                SELECT Id
                FROM Opportunity
                WHERE Id =: draftValues.values().get(0).OpportunityId
        ];

        for(OpportunityLineItem objItem : draftValues.values()) {
            if(objItem.Quantity == null || objItem.TotalPrice == null) {
                // Error 고의 발생 -> Helper에서 Error 메세지 띄움
                objOpp[0].addError(Label.isEmptyRequiredField);
            }
        }

        try {
            //upsert draftValues;
            //List<Database.SaveResult> results = Database.insert(draftValues.values(), true);

            List<Database.upsertResult> results = Database.upsert(draftValues.values(), true);
            System.debug('################### results : ' + results);
            return true;
        } catch(Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Map<Integer, OpportunityLineItem> doChangeValue(Id productId, Id recordId, Id itemId, String type, String targetValue, Map<Integer, OpportunityLineItem> mapUpdate, Integer idx){
        System.debug('[getResourcePrice] start ------------> ');
        System.debug('productId : ' + productId);
        System.debug('itemId : ' + itemId);
        System.debug('mapUpdate before : ' + mapUpdate);
        System.debug('targetValue : ' + targetValue);

        OpportunityLineItem objChangeItem = new OpportunityLineItem();

        if(mapUpdate == null) mapUpdate = new Map<Integer, OpportunityLineItem>();

        if(type != 'OpportunityLineItem') {
            if(mapUpdate.get(idx) == null){
                objChangeItem = getOpportunityLineItem(itemId);
                switch on type {
                    when 'Amount' {
                        objChangeItem.Quantity = Integer.valueOf(targetValue);
                    }
                    when 'Price' {
                        objChangeItem.UnitPrice = Double.valueOf(targetValue);
                    }
                    when 'Description' {
                        objChangeItem.Description = targetValue;
                    }
                }

                mapUpdate.put(idx, objChangeItem);
            } else {
                OpportunityLineItem objOppItem = mapUpdate.get(idx);
                System.debug('objOppItem : ' + objOppItem);
                switch on type {
                    when 'Amount' {
                        objOppItem.Quantity = Integer.valueOf(targetValue);
                    }
                    when 'Price' {
                        objOppItem.UnitPrice = Double.valueOf(targetValue);
                    }
                    when 'Description' {
                        objOppItem.Description = targetValue;
                    }
                }

                mapUpdate.put(idx, objOppItem);
            }
        } else {
            mapUpdate.put(idx, new OpportunityLineItem(OpportunityId = recordId, Product2Id = productId));
        }

        System.debug('mapUpdate after : ' + mapUpdate);
        return mapUpdate;
    }

    @AuraEnabled
    public static Map<Id, OpportunityLineItem> getResourcePrice(Id productId, Id recordId){
        System.debug('[getResourcePrice] start ------------> ');
        System.debug('productId : ' + productId);

        OpportunityLineItem objItem = new OpportunityLineItem(OpportunityId = recordId, Product2Id = productId);
        Map<Id, OpportunityLineItem> mapOppItem = new Map<Id, OpportunityLineItem>();
        mapOppItem.put(productId, objItem);

        System.debug('mapUpdate after : ' + mapOppItem);
        return mapOppItem;
    }
}