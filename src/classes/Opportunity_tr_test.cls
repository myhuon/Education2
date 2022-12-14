/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-13
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-13   hyunsoo.song@daeunextier.com   Initial Version
 */
@IsTest
private class Opportunity_tr_test {
    @TestSetup
    static void testSetup() {
        Account objAccount = TestUtils.createAccount();
        Opportunity objOpp1 = TestUtils.createOpportunity(objAccount.Id);
    }

    static testMethod void doTest() {
        List<Account> listAcc = [SELECT Id FROM Account LIMIT 1];

        test.startTest();
        Opportunity objOpp2 = TestUtils.createOpportunity(listAcc[0].Id);

        objOpp2.StageName = 'Closed Won';
        update objOpp2;
        delete objOpp2;
        undelete objOpp2;

        test.stopTest();
    }
}