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
}