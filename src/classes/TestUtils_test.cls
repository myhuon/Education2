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

@IsTest
private class TestUtils_test {
    @IsTest
    static void testBehavior() {
        Test.startTest();

        Account testAccount = TestUtils.createAccount();
        Opportunity testOppty = TestUtils.createOpportunity(testAccount.Id);

        Test.stopTest();
    }
}