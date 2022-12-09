/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-09
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-09   hyunsoo.song@daeunextier.com   Initial Version
 */
public class AccountDataController {

    @AuraEnabled (cacheable=true)
    public static List<Contact> fetchContact(){
        return [SELECT Id, Name, Account.Name, AccountId, Email
        FROM Contact LIMIT 10];
    }
}