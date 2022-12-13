/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-08
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-08   hyunsoo.song@daeunextier.com   Initial Version
 */
@IsTest
public with sharing class Evaluation1_test {

    static testMethod void doTest(){
        Evaluation1 evaluation1 = new Evaluation1();

        Test.startTest();

        System.debug('[getResult3And5] result : '+ evaluation1.getResult3And5(20));
        System.debug('[getStrPatternIntegerToString] result : '+evaluation1.getStrPatternIntegerToString(123, 5));
        System.debug('[getStrFormatYyyyMmDd] result : '+evaluation1.getStrFormatYyyyMmDd(Date.today()));

        Test.stopTest();
    }
}