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
        //String recordId = ApexPages.currentPage().GetParameters().get('recordId');

        /*List<OpportunityLineItem> listOpportunityLineItems = [
                SELECT Name, Product2Id, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id
                FROM OpportunityLineItem
                WHERE OpportunityId =: recordId
        ];*/
        List<OpportunityLineItem> listOpportunityLineItems = getOpportunityLineItems(recordId);

        System.debug('**************** recordId : ' + recordId);
        System.debug('%%%%%%%%%%%%%%%%%%% listOpp : ' + listOpportunityLineItems);

        return listOpportunityLineItems;
    }

    @AuraEnabled
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
    }

    @AuraEnabled
    public static OpportunityLineItem getResourcePrice(Id productId, Id recordId, Id itemId, String targetField, String targetValue){
        System.debug('[getResourcePrice] start ------------> ');

        //List<OpportunityLineItem> listOpportunityLineItems = getOpportunityLineItems(recordId);
        OpportunityLineItem objChangeItem = getOpportunityLineItem(itemId);

        if(objChangeItem != null) {
            switch on targetField {
                when 'qty' {
                    objChangeItem.Quantity = Integer.valueOf(targetValue);
                }
                when 'unitprice' {
                    objChangeItem.UnitPrice = Double.valueOf(targetValue);
                }
                when 'description' {
                    objChangeItem.Description = targetValue;
                }
            }
        }

        return objChangeItem;
        /*List<OpportunityLineItem> listReturnItems = new List<OpportunityLineItem>();
        for(OpportunityLineItem objItem : listOpportunityLineItems) {
            if(objItem.Id == id){
                switch on targetField {
                    when 'qty' {

                    }
                    when 'unitprice' {

                    }
                    when 'description' {

                    }
                }
            }

            listReturnItems.add(objItem);
        }*/
    }
}