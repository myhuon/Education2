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
/*
사전 준비
1. Account에 LeadSource__c MultiPicklist 필드를 생성하고 Opportunity의 LeadSource Picklist 값을 모두 추가
2. Account에 Grade__c Picklist 필드를 추가, 값은 A,B,C,D,E
3. Account에 GradeLastYear__c Picklist 필드를 추가, 값은 A,B,C,D,E

LeadSource는 'Other' 로 생성할 수 없음
LeadSource는 변경할 수 없음
단, 다른 클래스내에서 'Other' 로 생성할 수 있도록 처리가 되어야 함 (예외 처리를 할 수 있도록)

Opportunity가 IsWon 이고, ClosedDate가 올해인 Account 별 Amount 총액에 따라 Account의 GradeThisYear__c값에 Amount 총액별로 등급 업데이트
500만원미만 E, 500만원이상 D, 1000만원이상 C, 5000만원이상 B, 1억이상 A
단 작년등급 (GradeLastYear__c)가 높은 경우 작년등급으로 그대로 둠
예) Account "sample1" GradeLastYear__c 가 값이 없는 경우
Account "sample1" 에 IsWon된 Opportunity Amount 300만원 발생 -> Grade__c E
Account "sample1" 에 IsWon된 Opportunity Amount 300만원 추가발생 -> Grade__c D
Account "sample1" 에 IsWon된 Opportunity Amount 300만원 추가발생 -> Grade__c D 유지
Account "sample1" 에 IsWon된 Opportunity Amount 300만원 추가발생 -> Grade__c C
예) Account "sample1" GradeLastYear__c 가 D이고 Grade__c 가 D인 경우
Account "sample1" 에 IsWon된 Opportunity Amount 300만원 발생 -> Grade__c D 유지
Account "sample1" 에 IsWon된 Opportunity Amount 300만원 추가발생 -> Grade__c D 유지
Account "sample1" 에 IsWon된 Opportunity Amount 300만원 추가발생 -> Grade__c D 유지
Account "sample1" 에 IsWon된 Opportunity Amount 300만원 추가발생 -> Grade__c C

Opportunity가 등록될때마다 Opportunity의 LeadSource가 Account의 LeadSource__c에 포함되어 있지 않으면 Account의 LeadSource__c에 추가 선택된 걸로 업데이트
*/

public with sharing class Opportunity_tr {
    public static boolean isOtherClass = false;     // 다른 클래스에서 LeadSource 값을 Other로 생성할 수 있게 하는 기준 변수
    private Map<Id, Account> mapAccountUpdate = new Map<Id, Account>();

    List<Opportunity> listNew = Trigger.new;
    List<Opportunity> listOld = Trigger.old;
    Map<Id, Opportunity> mapNew = (Map<Id, Opportunity>) Trigger.newMap;
    Map<Id, Opportunity> mapOld = (Map<Id, Opportunity>) Trigger.oldMap;

    public void run() {
        if (Trigger.isBefore && Trigger.isInsert) beforeInsert();
        else if (Trigger.isBefore && Trigger.isUpdate) beforeUpdate();
        else if (Trigger.isBefore && Trigger.isDelete) beforeDelete();
        else if (Trigger.isAfter && Trigger.isInsert) afterInsert();
        else if (Trigger.isAfter && Trigger.isUpdate) afterUpdate();
        else if (Trigger.isAfter && Trigger.isDelete) afterDelete();
        else if (Trigger.isAfter && Trigger.isUndelete) afterUndelete();
    }

    private void beforeInsert() {
        //checkOtherLeadSource();
        validationOtherClass();
    }

    private void beforeUpdate() {
        displayErrorChangeLeadSource();
    }

    private void beforeDelete() {
        checkIsWonDelete();
    }

    private void afterInsert() {
        updateAccountLeadSource();

        if (!mapAccountUpdate.isEmpty()) update mapAccountUpdate.values();
    }

    private void afterUpdate() {
        updateAccountLeadSource();
        calcAccountGrade();

        if (!mapAccountUpdate.isEmpty()) update mapAccountUpdate.values();
    }

    private void afterDelete() {
        deleteAccountLeadSource();

        if (!mapAccountUpdate.isEmpty()) update mapAccountUpdate.values();
    }

    private void afterUndelete() {
        updateAccountLeadSource();

        if (!mapAccountUpdate.isEmpty()) update mapAccountUpdate.values();
    }

    // isOtherClass 정적변수가 false일 경우는 LeadSource를 'Other'로 생성할 수 없음
    private void validationOtherClass() {
        for (Opportunity obj : listNew) {
            if (obj.LeadSource == 'Other' && !isOtherClass && !Test.isRunningTest()) {
                obj.addError(Label.LeadSourceOtherValid);
            }
        }
    }

    // 기회가 isWon일 때 삭제 불가
    private void checkIsWonDelete() {
        for (Opportunity obj : listOld) {
            if (obj.IsWon && !Test.isRunningTest()) {
                obj.addError(Label.IsWonDeleteValid);
            }
        }
    }

    // checkOtherLeadSource() 대신 validationOtherClass()로 대체
    // API Enabled Profile을 가진 사용자가 기회 생성하는 경우가 아니라면, LeadSource 'Other'로 생성 불가능
    private void checkOtherLeadSource() {
        List<Opportunity> listTarget = new List<Opportunity>();

        for (Opportunity obj : listNew) {
            if (obj.LeadSource == 'Other') {
                listTarget.add(obj);
            }
        }

        if (!listTarget.isEmpty()) {
            Set<Id> setApiEnable = new Map<Id, Profile>([
                    SELECT Id
                    FROM Profile
                    WHERE PermissionsApiEnabled = :true
            ]).keySet();

            if (!setApiEnable.contains(UserInfo.getProfileId())) {
                for (Opportunity obj : listTarget) {
                    obj.addError(Label.LeadSourceOtherValid);
                }
            }
        }
    }

    // Account & Lead Source 변경 불가
    private void displayErrorChangeLeadSource() {
        for (Opportunity obj : listNew) {
            if (mapOld != null) {
                if (mapOld.get(obj.Id).LeadSource != obj.LeadSource) {
                    obj.addError(Label.LeadSourceValid);
                } else if (mapOld.get(obj.Id).AccountId != obj.AccountId) {
                    obj.addError(Label.AccountValidInOpp);
                }
            }
        }
    }

    // Opportunity 생성 시 관련 Account Lead Source 업데이트
    private void updateAccountLeadSource() {
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id, Set<String>> mapAccLeadSources = new Map<Id, Set<String>>();
        Set<String> setNewLeadSources = new Set<String>();

        for (Opportunity obj : listNew) {
            if (obj.LeadSource != null && obj.AccountId != null) {
                setAccountIds.add(obj.AccountId);
                if (mapAccLeadSources.get(obj.AccountId) != null) {
                    setNewLeadSources = mapAccLeadSources.get(obj.AccountId);
                } else {
                    setNewLeadSources = new Set<String>();
                }
                setNewLeadSources.add(obj.LeadSource);
                mapAccLeadSources.put(obj.AccountId, setNewLeadSources);
            }
        }

        if (!setAccountIds.isEmpty()) {
            Set<String> setLeadSource = new Set<String>();
            for (Account obj : [
                    SELECT Id, LeadSource__c
                    FROM Account
                    WHERE Id IN :mapAccLeadSources.keySet()
            ]) {
                if (obj.LeadSource__c != null) {
                    setLeadSource.addAll(obj.LeadSource__c.split(';'));
                }
                setLeadSource.addAll(mapAccLeadSources.get(obj.Id));

                obj.LeadSource__c = String.join((Iterable<String>) setLeadSource, ';');
                mapAccountUpdate.put(obj.Id, obj);
            }
        }
    }

    // 기회 삭제 시 관련 Account LeadSource 확인
    private void deleteAccountLeadSource() {
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id, Set<String>> mapAccLeadSources = new Map<Id, Set<String>>();

        for (Opportunity obj : listOld) {
            if (obj.LeadSource != null && obj.AccountId != null) {
                setAccountIds.add(obj.AccountId);
            }
        }

        if (!setAccountIds.isEmpty()) {
            Set<String> setLeadSource = new Set<String>();
            for (Opportunity obj : [
                    SELECT Id, LeadSource, AccountId
                    FROM Opportunity
                    WHERE AccountId IN :setAccountIds
            ]) {
                if (mapAccLeadSources.get(obj.AccountId) != null) {
                    setLeadSource = mapAccLeadSources.get(obj.Id);
                }
                setLeadSource.add(obj.LeadSource);
                mapAccLeadSources.put(obj.AccountId, setLeadSource);
            }

            for (Account obj : [
                    SELECT Id, LeadSource__c
                    FROM Account
                    WHERE Id IN :setAccountIds
            ]) {
                if (mapAccLeadSources.get(obj.Id) != null) {
                    obj.LeadSource__c = String.join((Iterable<String>) mapAccLeadSources.get(obj.Id), ';');
                } else {
                    obj.LeadSource__c = '';
                }
                mapAccountUpdate.put(obj.Id, obj);
            }
        }
    }

    // 기회가 IsWon으로 변경됐을 때, 관련 Account의 Grade 계산
    private void calcAccountGrade() {
        Set<Id> setAccountIds = new Set<Id>();

        for (Opportunity obj : listNew) {
            if (mapOld.get(obj.Id).IsWon != obj.IsWon && obj.AccountId != null && obj.CloseDate.year() == Date.today().year() && obj.Amount != null) {
                setAccountIds.add(obj.AccountId);
            }
        }

        if (!setAccountIds.isEmpty()) {
            List<AggregateResult> listResults = [
                    SELECT AccountId, Sum(Amount) amount
                    FROM Opportunity
                    WHERE AccountId IN :setAccountIds AND IsWon = TRUE AND CALENDAR_YEAR(CloseDate) = :Date.today().year()
                    GROUP BY AccountId
            ];

            Map<Id, Decimal> mapResult = new Map<Id, Decimal>();
            for (AggregateResult obj : listResults) {
                mapResult.put((Id) obj.get('AccountId'), (Decimal) obj.get('amount')); // 꺼내오는 필드 값이 object 형태로 가져와서 타입 캐스팅 필요
            }

            String strGrade = '';
            Decimal totalAmount = 0;
            for (Account objAccount : [
                    SELECT Id, GradeLastYear__c, Grade__c, IsWonOppTotalAmount__c
                    FROM Account
                    WHERE Id IN :setAccountIds
            ]) {
                totalAmount = mapResult.get(objAccount.Id);
                if (totalAmount >= Decimal.valueOf(Label.GradeA)) {
                    strGrade = 'A';
                } else if (totalAmount >= Decimal.valueOf(Label.GradeB)) {
                    strGrade = 'B';
                } else if (totalAmount >= Decimal.valueOf(Label.GradeC)) {
                    strGrade = 'C';
                } else if (totalAmount >= Decimal.valueOf(Label.GradeD)) {
                    strGrade = 'D';
                } else {
                    strGrade = 'E';
                }

                if (objAccount.GradeLastYear__c != null && objAccount.GradeLastYear__c < strGrade) {
                    objAccount.Grade__c = objAccount.GradeLastYear__c;
                } else {
                    objAccount.Grade__c = strGrade;
                }

                mapAccountUpdate.put(objAccount.Id, objAccount);
            }
        }
    }
}