/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-21
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-21   hyunsoo.song@daeunextier.com   Initial Version
 */

@IsTest
public with sharing class OpportunityLineItem_tr_test {
    @TestSetup
    static void testSetup() {
        Account objAccount = TestUtils.createAccount();
        Opportunity objOpp = TestUtils.createOpportunity(objAccount.Id);
        Product2 objProduct = TestUtils.createProduct2();
        PricebookEntry objPBE = TestUtils.createPricebookEntry(objProduct.Id);
    }

    static testMethod void doTest() {
        List<Opportunity> listOpp = [SELECT Id FROM Opportunity LIMIT 2];
        List<PricebookEntry> listPBE = [SELECT Id FROM PricebookEntry LIMIT 2];

        test.startTest();

        OpportunityLineItem objOppItem = TestUtils.createOpportunityLineItem(listOpp[0].Id, listPBE[0].Id);
        delete objOppItem;

        test.stopTest();
    }
}