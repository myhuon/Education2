/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-22
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-22   hyunsoo.song@daeunextier.com   Initial Version
 */

@RestResource(urlMapping='/util/exchangerate')
global with sharing class Evaluation3 implements ExchangeRate_interface {

    // HttpGet은 Salesforce record 반환 시 사용됨
/*    @HttpGet
    global static void ExchangeRateInfo() {
        System.debug('HttpGet !!');
    }*/

    @HttpPost
    global static  Map<String, Integer> ExchangeRateInfo(String currencyisocode) {
        System.debug('[ExchangeRateInfo] POST ------------> start!');

        Integer exchangeRate = 0;
        if(currencyisocode == 'usd') {
            exchangeRate = Integer.valueof(Math.random() * 100 + 1200);
        }
        System.debug('[Evaluation3] exchange : ' + exchangeRate);

        Map<String, Integer> mapExchangeRate = new Map<String, Integer>{'exchaneRate' => exchangeRate};

        System.debug('[ExchangeRateInfo] POST ------------> end!');
        return mapExchangeRate;
    }
}

