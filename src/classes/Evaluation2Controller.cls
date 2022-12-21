/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-12
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-12   hyunsoo.song@daeunextier.com   Initial Version
 */
public with sharing class Evaluation2Controller {
    // 기회의 모든 제품들 반환
    private static List<OpportunityLineItem> getOpportunityLineItems(String recordId) {
        List<OpportunityLineItem> listOpportunityLineItems = [
                SELECT Name, Product2.Name, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id, SortOrder
                FROM OpportunityLineItem
                WHERE OpportunityId = :recordId
                ORDER BY SortOrder
        ];

        return listOpportunityLineItems;
    }

    // 하나의 기회 제품 반환
    private static OpportunityLineItem getOpportunityLineItem(String itemId) {
        List<OpportunityLineItem> listOpportunityLineItems = [
                SELECT Name, Product2Id, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id, SortOrder
                FROM OpportunityLineItem
                WHERE Id = :itemId
                LIMIT 1
        ];

        if (!listOpportunityLineItems.isEmpty()) return listOpportunityLineItems[0];
        return null;
    }

    @AuraEnabled
    public static List<OpportunityLineItem> getInitData(String recordId) {
        List<OpportunityLineItem> listOpportunityLineItems = getOpportunityLineItems(recordId);

        return listOpportunityLineItems;
    }

    @AuraEnabled
    public static boolean saveRecord(Map<Integer, OpportunityLineItem> draftValues) {

        for (OpportunityLineItem objItem : draftValues.values()) {
            System.debug('[saveRecord] objItem.SortOrder : ' + objItem.SortOrder);
            System.debug('[saveRecord] objItem : ' + objItem);
            if (objItem.Quantity == null || objItem.UnitPrice == null || objItem.Product2Id == null) {
                return false;
            }
        }

        //List<Database.upsertResult> results = Database.upsert(draftValues.values(), false);
//        upsert draftValues.values() Id;

        List<OpportunityLineItem> listTemp = new List<OpportunityLineItem>();
        for(OpportunityLineItem obj:draftValues.values()) {
            OpportunityLineItem objUnit = new OpportunitylineItem();
            if(obj.Id == null) {
                objUnit.OpportunityId = obj.OpportunityId;
                objUnit.Product2Id = obj.Product2Id;
            }
            objUnit.Id = obj.Id;
            objUnit.SortOrder = obj.SortOrder;
            objUnit.UnitPrice = obj.UnitPrice;
            objUnit.Description = obj.Description;
            objUnit.TotalPrice = obj.TotalPrice;
            objUnit.Quantity = obj.Quantity;
            listTemp.add(objUnit);
        }
        upsert listTemp;
        return true;
    }

    @AuraEnabled
    public static boolean deleteRecord(List<Id> listDeleteTargetId) {
        try {
            List<Database.DeleteResult> results = Database.delete(listDeleteTargetId, true);
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }

    @AuraEnabled
    public static Map<Integer, OpportunityLineItem> doChangeValue(Id productId, Id recordId, Id itemId, String type, String targetValue, Map<Integer, OpportunityLineItem> mapUpdate, Integer idx) {
        if (mapUpdate == null) mapUpdate = new Map<Integer, OpportunityLineItem>();

        if (type != 'OpportunityLineItem') {
            OpportunityLineItem objChangeItem;
            if (mapUpdate.get(idx) == null) {
                objChangeItem = idx != null ? getOpportunityLineItem(itemId) : new OpportunityLineItem();
            } else {
                objChangeItem = mapUpdate.get(idx);
            }

            mapUpdate.put(idx, returnChangeItem(objChangeItem, targetValue, type));
        } else {
            mapUpdate.put(idx, new OpportunityLineItem(OpportunityId = recordId, Product2Id = productId));
        }

        System.debug('mapUpdate : ' + mapUpdate);
        return mapUpdate;
    }

    @AuraEnabled
    public static Map<Integer, OpportunityLineItem> doMoveRow(Map<Integer, OpportunityLineItem> mapUpdate, List<OpportunityLineItem> listData, Integer idx, Boolean isUp) {
        System.debug('[doMoveRow] ====================> start! ');
        if (mapUpdate == null) mapUpdate = new Map<Integer, OpportunityLineItem>();
        OpportunityLineItem objMove = new OpportunityLineItem();
        OpportunityLineItem obj = new OpportunityLineItem();
        Integer objIdx = 0;

        obj = mapUpdate.get(idx) == null ? listData[idx] : mapUpdate.get(idx);
        if (isUp) {
            objIdx = idx - 1;
            objMove = mapUpdate.get(objIdx) == null ? listData[objIdx] : mapUpdate.get(objIdx);

            obj.SortOrder -= 1;
            objMove.SortOrder += 1;
        } else {
            objIdx = idx + 1;
            objMove = mapUpdate.get(objIdx) == null ? listData[objIdx] : mapUpdate.get(objIdx);

            obj.SortOrder += 1;
            objMove.SortOrder -= 1;
        }

        mapUpdate.put(objIdx, obj);
        mapUpdate.put(idx, objMove);

        System.debug('[doMoveRow] sortOrder : ' + obj.SortOrder + ' / ' + objMove.SortOrder);

        System.debug('[doMoveRow] ====================> end! ');
        return mapUpdate;
    }

    private static OpportunityLineItem returnChangeItem(OpportunityLineItem objChangeItem, String targetValue, String type) {

        switch on type {
            when 'Amount' {
                objChangeItem.Quantity = targetValue != '' ? Integer.valueOf(targetValue) : null;
            }
            when 'Price' {
                objChangeItem.UnitPrice = targetValue != '' ? Double.valueOf(targetValue) : null;
            }
            when 'Description' {
                objChangeItem.Description = targetValue;
            }
        }

        return objChangeItem;
    }
}