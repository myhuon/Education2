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
                SELECT Name, Product2.Name, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id
                FROM OpportunityLineItem
                WHERE OpportunityId =: recordId
                ORDER BY CreatedDate
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

        return listOpportunityLineItems;
    }

    @AuraEnabled
    public static boolean saveRecord(Map<String, OpportunityLineItem> draftValues){
        try {
            List<Database.upsertResult> results = Database.upsert(draftValues.values(), true);
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static boolean deleteRecord(List<Id> listDeleteTargetId) {
        try {
            List<Database.DeleteResult> results = Database.delete(listDeleteTargetId, true);
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static Map<Integer, OpportunityLineItem> doChangeValue(Id productId, Id recordId, Id itemId, String type, String targetValue, Map<Integer, OpportunityLineItem> mapUpdate, Integer idx){
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
                        objChangeItem.UnitPrice = targetValue == '' ? 0.0 : Double.valueOf(targetValue);
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
                        objOppItem.UnitPrice = targetValue == '' ? 0.0 : Double.valueOf(targetValue);
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


        return mapUpdate;
    }
}