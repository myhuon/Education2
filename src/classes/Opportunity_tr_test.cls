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
    static testMethod void doTest() {
        Account objAccount = new Account();
        objAccount.Name = '테스트Account';
        insert objAccount;

        Opportunity obj = new Opportunity();
        obj.Name = '테스트Opportunity';
        obj.AccountId = objAccount.Id;
        obj.StageName = 'Closed Won';
        obj.CloseDate = System.today();

        test.startTest();

        insert obj;
        update obj;
        delete obj;
        undelete obj;

        test.stopTest();
    }
}