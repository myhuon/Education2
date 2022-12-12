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
    @AuraEnabled
    public static List<OpportunityLineItem> getInitData(String recordId) {
        //String recordId = ApexPages.currentPage().GetParameters().get('recordId');

        List<OpportunityLineItem> listOpportunityLineItems = [
                SELECT Name, Product2Id, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id
                FROM OpportunityLineItem
                WHERE OpportunityId =: recordId
        ];

        System.debug('**************** recordId : ' + recordId);
        System.debug('%%%%%%%%%%%%%%%%%%% listOpp : ' + listOpportunityLineItems);

        return listOpportunityLineItems;
    }

    @AuraEnabled
    public static boolean updateRecord(List<OpportunityLineItem> draftValues){
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
}