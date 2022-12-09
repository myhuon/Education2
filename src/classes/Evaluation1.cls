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
public with sharing class Evaluation1 {
    /**
     * @param intValue 입력값
     * @return 결과값
     * @description 1부터 입력값까지의 3의배수, 5의배수 값의 합
     * 예) 입력값 10이면 3,5,6,9,10를 더한 33, 입력값이 20이면 3,5,6,9,10,12,15,18,20를 더한 98
     */
    public Integer getResult3And5(Integer intValue) {
        Integer intResult = 0;

        for(Integer num = 1; num <= intValue; num++){
            if(Math.mod(num, 3) == 0 || Math.mod(num, 5) == 0) {
                intResult += num;
            }
        }

        return intResult;
    }

    /**
     * @param intValue 입력숫자
     * @param intDigit 자리수
     * @return 결과값
     * @description 입력숫자에 자리수 만큼 0를 붙여 Return, 자리수가 입력숫자보다 적을 경우는 그냥 입력숫자 return
     * 예) 입력값이 123, 5 이면 00123, 입력값이 123, 2 이면 123, 입력값이 1234, 8 이면 00001234
     */
    public String getStrPatternIntegerToString(Integer intValue, Integer intDigit) {
        String strReturn = '';
        Integer cnt = 0;
        Integer divIntValue = intValue;

        while(divIntValue > 0){
            divIntValue /= 10;
            cnt++;
        }

        if(cnt < intDigit) {
            Integer loopNum = intDigit - cnt;
            for (Integer i = 0; i < loopNum; i++) {
                strReturn += '0';
            }
        }
        strReturn += String.valueOf(intValue);

        return strReturn;
    }

    /**
     * @param dtValue 입력날짜
     * @return 결과값
     * @description 입력날짜를 yyyymmdd 형식의 String으로 Return
     * 예) 2022-12-01 이면 '20221201' 로 return
     */
    public String getStrFormatYyyyMmDd(Date dtValue) {
        String strReturn;

        strReturn = String.valueOf(DateTime.newInstance(dtValue.year(), dtValue.month(), dtValue.day()).format('yyyyMMdd'));

        return strReturn;
    }
}