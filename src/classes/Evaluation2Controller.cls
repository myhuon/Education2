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

        Integer seq = 0;
        for (OpportunityLineItem obj : listOpportunityLineItems) {
            if (obj.SortOrder == null) {
                obj.SortOrder = seq;
            }
            seq += 1;

            System.debug('Sortorder : ' + obj.SortOrder);
        }
        //System.debug('sortorder : ' + listOpportunityLineItems[0].SortOrder);

        return listOpportunityLineItems;
    }

    // 하나의 기회 제품 반환
    private static OpportunityLineItem getOpportunityLineItem(String itemId) {
        List<OpportunityLineItem> listOpportunityLineItems = [
                SELECT Name, Product2Id, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id
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
    public static boolean saveRecord(Map<Id, OpportunityLineItem> draftValues) {
        Set<Integer> setSortOrderNum = new Set<Integer>();
        List<OpportunityLineItem> listTemp = new List<OpportunityLineItem>();

        for (OpportunityLineItem objItem : draftValues.values()) {
            System.debug('[saveRecord] objItem : ' + objItem);

            if (objItem.Quantity == null || objItem.UnitPrice == null || objItem.Product2Id == null) {
                return false;
            }
        }

        List<Database.upsertResult> results = Database.upsert(draftValues.values(), true);
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
    public static Map<Id, OpportunityLineItem> doChangeValue(Id productId, Id recordId, Id itemId, String type, String targetValue, Map<Id, OpportunityLineItem> mapUpdate, Integer idx) {
        if (mapUpdate == null) mapUpdate = new Map<Id, OpportunityLineItem>();

        if (type != 'OpportunityLineItem') {
            OpportunityLineItem objChangeItem;
            if (mapUpdate.get(itemId) == null) {
                objChangeItem = itemId != null ? getOpportunityLineItem(itemId) : new OpportunityLineItem();
            } else {
                objChangeItem = mapUpdate.get(itemId);
            }

            mapUpdate.put(itemId, returnChangeItem(objChangeItem, targetValue, type));
        } else {
            mapUpdate.put(itemId, new OpportunityLineItem(OpportunityId = recordId, Product2Id = productId));
        }

        System.debug('mapUpdate : ' + mapUpdate);
        return mapUpdate;
    }

    @AuraEnabled
    public static List<OpportunityLineItem> doAddRowChangeValue(Id productId, Id recordId, Integer listDataSize, String type, String targetValue, List<OpportunityLineItem> listUpdate, Integer idx) {

        if (listUpdate == null) {
            listUpdate = new List<OpportunityLineItem>();

            for (Integer i = 0; i < listDataSize; i++) {
                listUpdate[i] = null;
            }
        }

        if (idx != null) {
            OpportunityLineItem objChangeItem;
            if (listUpdate.size() >= idx) {
                objChangeItem = listUpdate[idx];
            } else {
                listUpdate[idx] = new OpportunityLineItem(OpportunityId = recordId, Product2Id = productId);
            }

            listUpdate[idx] = returnChangeItem(objChangeItem, targetValue, type);
        }

        System.debug('listUpdate : ' + listUpdate);
        return listUpdate;
    }

    @AuraEnabled
    public static Map<Id, OpportunityLineItem> doMoveRow(Map<Id, OpportunityLineItem> mapUpdate, List<OpportunityLineItem> listData, Integer idx, Boolean isUp) {
        if (mapUpdate == null) mapUpdate = new Map<Id, OpportunityLineItem>();

        System.debug('[doMoveRow] ====================> start! ');
        Map<Integer, OpportunityLineItem> mapTemp = new Map<Integer, OpportunityLineItem>();
        OpportunityLineItem objMove = listData[idx - 1];
        OpportunityLineItem obj = listData[idx];

        if (isUp) {
            System.debug('[doMoveRow] ====================> isUp ');
            SObjectType r = ((SObject) (Type.forName('Schema.OpportunityLineItem').newInstance())).getSObjectType();
            DescribeSObjectResult d = r.getDescribe();
            System.debug('[doMoveRow]  sort order type : ' + d.fields.getMap()
                    .get('SortOrder')
                    .getDescribe()
                    .getType());
            if (mapUpdate.get(obj.Id) != null) {
                obj = mapUpdate.get(obj.Id);
                obj.SortOrder -= 1;
                mapUpdate.put(obj.Id, obj);
            } else {
                obj.SortOrder -= 1;
                mapUpdate.put(obj.Id, obj);
            }

            if (mapUpdate.get(objMove.Id) != null) {
                objMove = mapUpdate.get(objMove.Id);
                objMove.SortOrder += 1;
                mapUpdate.put(objMove.Id, objMove);
            } else {
                objMove.SortOrder += 1;
                mapUpdate.put(objMove.Id, objMove);
            }
        } /*else {
            if(mapUpdate.get(obj.Id) != null) mapUpdate.get(obj.Id).SortOrder += 1;
            else {
                obj.SortOrder += 1;
                mapUpdate.put(obj.Id, obj);
            }

            objMove = listData[idx + 1];
            if(mapUpdate.get(objMove.Id) != null) mapUpdate.get(objMove.Id).SortOrder -= 1;
            else {
                objMove.SortOrder -= 1;
                mapUpdate.put(objMove.Id, objMove);
            }
        }*/

        System.debug('mapUpdate : ' + mapUpdate);
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