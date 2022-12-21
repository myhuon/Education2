/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-21
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-21   hyunsoo.song@daeunextier.com   Initial Version
 */
public with sharing class OpportunityLineItem_tr {
    private Map<Id, Account> mapAccountUpdate = new Map<Id, Account>();

    List<OpportunityLineItem> listNew = Trigger.new;
    List<OpportunityLineItem> listOld = Trigger.old;
    Map<Id, OpportunityLineItem> mapNew = (Map<Id, OpportunityLineItem>) Trigger.newMap;
    Map<Id, OpportunityLineItem> mapOld = (Map<Id, OpportunityLineItem>) Trigger.oldMap;

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
        doSortValueSetting();
    }

    private void beforeUpdate() { }

    private void beforeDelete() { }

    private void afterInsert() { }

    private void afterUpdate() { }

    private void afterDelete() { }

    private void afterUndelete() { }

    private void doSortValueSetting() {
        System.debug('[doSortValueSetting] trigger start!');
        Set<Id> setOpp = new Set<Id>();
        List<OpportunityLineItem> listTarget = new List<OpportunityLineItem>();

        for (OpportunityLineItem obj : listNew) {
            if(obj.OpportunityId != null) {
                setOpp.add(obj.OpportunityId);
                listTarget.add(obj);
            }
        }

        if(!setOpp.isEmpty()) {
            Map<Id, Integer> mapOppMaxSortNum = new Map<Id, Integer>();
            for(AggregateResult obj : [
                    SELECT MAX(SortOrder) maxOrder, OpportunityId
                    FROM OpportunityLineItem
                    WHERE OpportunityId IN: setOpp
                    GROUP BY OpportunityId
            ]) {
                mapOppMaxSortNum.put((Id)obj.get('OpportunityId'), (Integer)obj.get('maxOrder'));
            }

            for(OpportunityLineItem obj : listTarget) {
                if(mapOppMaxSortNum.get(obj.OpportunityId) != null) {
                    obj.SortOrder = mapOppMaxSortNum.get(obj.OpportunityId) + 1;
                } else {
                    obj.SortOrder = 1;
                }
                mapOppMaxSortNum.put(obj.OpportunityId, obj.SortOrder);
            }
        }

        System.debug('[doSortValueSetting] trigger end!');
    }
}