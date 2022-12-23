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
                SELECT Name, Product2.Name, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id, SortOrder, PricebookEntryId, ExchangeRate__c, UsdTotalPrice__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :recordId
                ORDER BY SortOrder
        ];

        for(OpportunityLineItem obj : listOpportunityLineItems) {
            System.debug('getInit order : ' + obj.SortOrder);
        }

        return listOpportunityLineItems;
    }

    // 하나의 기회 제품 반환
    private static OpportunityLineItem getOpportunityLineItem(String itemId) {
        List<OpportunityLineItem> listOpportunityLineItems = [
                SELECT Name, Product2Id, ListPrice, UnitPrice, Quantity, TotalPrice, Description, Id, SortOrder, PricebookEntryId, ExchangeRate__c, UsdTotalPrice__c
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
        Set<Id> setOppId = new Set<Id>();

        for (OpportunityLineItem objItem : draftValues.values()) {
            System.debug('[saveRecord] objItem.SortOrder : ' + objItem.SortOrder);
            System.debug('[saveRecord] objItem : ' + objItem);
            if (objItem.Quantity == null || objItem.UnitPrice == null) {
                return false;
            }

            setOppId.add(objItem.OpportunityId);
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
                doOppPriceBookUpdate(listTarget);
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
    public static boolean deleteRecord(List<Id> listDeleteTargetId, List<Id> listDeleteTargetOppId) {
        /*for(OpportunityLineItem obj : [
                SELECT Id, SortOrder
                FROM OpportunityLineItem
                WHERE OpportunityId IN: listDeleteTargetOppId
                ORDER BY SortOrder
        ]) {

        }*/

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
            Integer exchangeRate = returnExchangeRate();
            mapUpdate.put(idx, new OpportunityLineItem(OpportunityId = recordId, Product2Id = productId, ExchangeRate__c = exchangeRate));
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

    private static void doOppPriceBookUpdate(List<Opportunity> listTarget) {
        List<Opportunity> listUpdate = new List<Opportunity>();
        Pricebook2 objStandardPB2 = [SELECT Id, Name, IsActive FROM PriceBook2 WHERE IsStandard = TRUE LIMIT 1];

        for(Opportunity objOpp : listTarget) {
            objOpp.Pricebook2Id = objStandardPB2.Id;
            listUpdate.add(objOpp);
        }

        if(!listUpdate.isEmpty()) {
            update listUpdate;
        }
    }

    private static OpportunityLineItem returnChangeItem(OpportunityLineItem objChangeItem, String targetValue, String type) {

        switch on type {
            when 'Amount' {
                objChangeItem.Quantity = targetValue != '' ? Integer.valueOf(targetValue) : 0;
            }
            when 'Price' {
                objChangeItem.UnitPrice = targetValue != '' ? Double.valueOf(targetValue) : 0.0;
            }
            when 'Description' {
                objChangeItem.Description = targetValue;
            }
        }

        return objChangeItem;
    }

    private static Integer returnExchangeRate() {
        Integer exchangeRate = 0;
/*        Map<String, String> mapT = new Map<String, String>();
        mapT.put('currencyisocode', 'usd');*/


        RestRequest request = RestContext.request;
        request.httpMethod = 'POST';
        request.params.put('currencyisocode', 'usd');
        request.requestURI = '/util/exchangerate';
        System.debug('request : ' + request);


        RestResponse response = RestContext.response;
        System.debug('reponse : ' + response);


        // HttpRequest setting
        /*Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://daeunextier66-dev-ed.develop.lightning.force.com/services/apexrest/util/exchangerate');
        request.setBody('{"currencyisocode":"usd"}');
        request.setMethod('POST');
        request.setTimeout(120000);

        System.debug('[returnExchangeValue] request : ' + request);

        // received HttpResponse
        HttpResponse response = http.send(request);
        System.debug('[reuturnExchangeValue] res : ' + response);
        //if(response.getStatusCode() == 200) {
            Map<String, Object> mapResult = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            exchangeRate = (Integer) mapResult.get('exchangeRate');

            System.debug('[returnExchangeValue] mapResult : ' + mapResult);
            System.debug('[returnExchangeValue] exchangeRate : ' + exchangeRate);*/
        //}

        return exchangeRate;
    }
}