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
    private Map<Id, OpportunityLineItem> mapItemUpdate = new Map<Id, OpportunityLineItem>();

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
        //doPriceBookSetting();
        doSortValueSetting();
    }

    private void beforeUpdate() { }

    private void beforeDelete() { }

    private void afterInsert() { }

    private void afterUpdate() { }

    private void afterDelete() {
        doSortValueUpdate();

        if(!mapItemUpdate.isEmpty()) update mapItemUpdate.values();
    }

    private void afterUndelete() { }

    private void doPriceBookSetting() {
        System.debug('[doPriceBookSetting] trigger start!');
        Set<Id> setOppId = new Set<Id>();

        for(OpportunityLineItem obj : listNew) {
            if(obj.OpportunityId != null && obj.Product2Id != null) {
                setOppId.add(obj.OpportunityId);
            }
        }

        if(!setOppId.isEmpty()) {
            List<Opportunity> listTarget = new List<Opportunity>();
            for(Opportunity objOpp : [
                    SELECT Pricebook2Id
                    FROM Opportunity
                    WHERE Id =: setOppId AND Pricebook2Id =: null
            ]) {
                listTarget.add(objOpp);
            }

            if(!listTarget.isEmpty()) {
                Pricebook2 objStandardPB2 = [SELECT Id, Name, IsActive FROM PriceBook2 WHERE IsStandard=TRUE LIMIT 1];

                System.debug('objStandardPB2 : ' + objStandardPB2);
                for(Opportunity objOpp : listTarget) {
                    objOpp.Pricebook2Id = objStandardPB2.Id;
                }
            }
        }

        System.debug('[doPriceBookSetting] trigger end!');
    }

    private void doSortValueSetting() {
        System.debug('[doSortValueSetting] trigger start!');
        Set<Id> setOppId = new Set<Id>();
        List<OpportunityLineItem> listTarget = new List<OpportunityLineItem>();

        for (OpportunityLineItem obj : listNew) {
            if(obj.OpportunityId != null) {
                setOppId.add(obj.OpportunityId);
                listTarget.add(obj);
            }
        }

        if(!setOppId.isEmpty()) {
            Map<Id, Integer> mapOppMaxSortNum = new Map<Id, Integer>();

            for(AggregateResult obj : [
                    SELECT MAX(SortOrder) maxOrder, OpportunityId
                    FROM OpportunityLineItem
                    WHERE OpportunityId IN: setOppId
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

    private void doSortValueUpdate() {
        System.debug('[doSortValueUpdate] trigger start!');
        Map<Id, Integer> mapRemoveSortNum = new Map<Id, Integer>();

        for (OpportunityLineItem obj : listOld) {
            if(obj.OpportunityId != null) {
                mapRemoveSortNum.put(obj.OpportunityId, obj.SortOrder);
            }
        }

        if(!mapRemoveSortNum.isEmpty()) {
            Map<Id, List<OpportunityLineItem>> mapListItems = new Map<Id, List<OpportunityLineItem>>();
            List<OpportunityLineItem> listItems = new List<OpportunityLineItem>();

            for(OpportunityLineItem obj : [
                    SELECT Id, SortOrder, OpportunityId
                    FROM OpportunityLineItem
                    WHERE OpportunityId IN: mapRemoveSortNum.keySet()
                    ORDER BY SortOrder
            ]) {
                if(mapListItems.get(obj.OpportunityId) == null) listItems = new List<OpportunityLineItem>();
                else listItems = mapListItems.get(obj.OpportunityId);

                obj.SortOrder = listItems.size() + 1;
                listItems.add(obj);
                mapListItems.put(obj.OpportunityId, listItems);
            }

            for(List<OpportunityLineItem> listOpp : mapListItems.values()) {
                mapItemUpdate.putAll(listOpp);
            }
        }

        System.debug('[doSortValueUpdate] trigger end!');
    }
}