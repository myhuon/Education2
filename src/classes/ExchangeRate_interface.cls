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


public interface ExchangeRate_interface {
    //Integer ExchangeRateInfo();
    Map<String, Integer> ExchangeRateInfo(String currencyisocode);
}