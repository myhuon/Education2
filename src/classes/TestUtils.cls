/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-14
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-14   hyunsoo.song@daeunextier.com   Initial Version
 */

public with sharing class TestUtils {

    private static Account objAccount;
    public static Account createAccount(){
        if(objAccount == null) objAccount = new Account();

        objAccount.Name = '테스트Account';

        insert objAccount;
        return objAccount;
    }

    private static Opportunity objOpp;
    public static Opportunity createOpportunity(Id accountId){
        if(objOpp == null) objOpp = new Opportunity();

        objOpp.Name = '테스트Opportunity';
        objOpp.AccountId = accountId;
        objOpp.StageName = 'Prospecting';
        objOpp.CloseDate = System.today();
        objOpp.LeadSource = 'Other';
        objOpp.Amount = 10000;

        insert objOpp;
        return objOpp;
    }

    private static Product2 objProduct2;
    public static Product2 createProduct2(){
        if(objProduct2 == null) objProduct2 = new Product2();

        objProduct2.Name = '테스트Product2';
        objProduct2.IsActive = true;

        insert objProduct2;
        return objProduct2;
    }

    private static PricebookEntry objPricebookEntry;
    public static PricebookEntry createPricebookEntry(Id ProductId){
        if(objPricebookEntry == null) objPricebookEntry = new PricebookEntry();

        objPricebookEntry.IsActive = true;
        objPricebookEntry.UnitPrice = 15000;
        objPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        objPricebookEntry.Product2Id = ProductId;

        insert objPricebookEntry;
        return objPricebookEntry;
    }

    private static OpportunityLineItem objOppItem;
    public static OpportunityLineItem createOpportunityLineItem(Id OppId, Id PBEId) {
        if(objOppItem == null) objOppItem = new OpportunityLineItem();

        objOppItem.OpportunityId = OppId;
        objOppItem.PricebookEntryId = PBEId;
        objOppItem.UnitPrice = 10000;
        objOppItem.Quantity = 200;

        insert objOppItem;
        return objOppItem;
    }
}