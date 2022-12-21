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
({
    // Null , Undefined , '' 체크
            isNullCheck : function(value){
                if(value == null || value == undefined || value == "" || value == ''){
                    return true;
                }
                else{
                    return false;
                }
            },

            showToast: function (type, message) {
                var evt = $A.get("e.force:showToast");
                evt.setParams({
                    key: "info_alt",
                    type: type,
                    message: message
                });
                evt.fire();
            },

            getInitData: function (component, event, helper) {
                console.log('[getInitData] Start =============================>');
                var action = component.get("c.getInitData");
                action.setParams({
                    recordId: component.get("v.recordId"),
                });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var listData = response.getReturnValue();
                        console.log('[getInitData] result', listData);
                        if (listData.length != 0) {
                            component.set("v.listData", listData);
                            component.set("v.listDeleteTargetId", []);
                            component.set("v.listSelectedData", []);
                            component.set("v.listUpdate", []);
                            component.set("v.mapUpdate", {});
                            component.find("selectAll").set("v.checked", false);
                        }
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                        } else {
                            this.showToast("error", "Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
                console.log('[getInitData] End ==============================>');
            },

            doSave: function (component, event, helper, draftValues) {
                console.log('[doSave] Start ==============================>');
                component.set("v.toggleSpinner", true);

                var action = component.get("c.saveRecord");
                action.setParams({
                    draftValues : draftValues
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('[doSave] result : ' + result);
                        if(result) {
                            component.set("v.mapUpdate", {});
                            helper.showToast("success", "Save Success!");
                            console.log('[doSave] SUCCESS!!! ==============================>');
                            $A.get('e.force:refreshView').fire();
                        } else {
                            this.showToast("error", $A.get("$Label.c.isEmptyRequiredField"));
                        }
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        console.log('[doSave] error : ' + errors[0].message);
                        if (errors) {
                            if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                        } else {
                            this.showToast("error", "Unknown error");
                        }
                    }
                });
                component.set("v.toggleSpinner", false);
                $A.enqueueAction(action);
                console.log('[doSave] End ==============================>');
            },

            deleteRow: function (component, event, helper, listDeleteTargetId) {
                console.log('[deleteRow] Start ==============================>');
                component.set("v.toggleSpinner", true);
                var action = component.get("c.deleteRecord");
                action.setParams({
                    listDeleteTargetId: listDeleteTargetId
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        this.showToast('success', "Delete Success!");
                        component.set("v.listDeleteTargetId", []);
                        component.set("v.listSelectedData", []);
                        component.find("selectAll").set("v.checked", false);
                        console.log('[deleteRow] Delete!!! ==============================>');
                        $A.get('e.force:refreshView').fire();
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                        } else {
                            this.showToast("error", "Unknown error");
                        }
                    }
                    component.set("v.toggleSpinner", false);
                });
                $A.enqueueAction(action);
                console.log('[deleteRow] End ==============================>');
            },

            changeValue: function (component, event, helper, type, idx, targetValue) {
                console.log('[changeValue] Start ==============================>');
                component.set("v.toggleSpinner", true);

                let ListData = component.get("v.listData");
                let objData = ListData[idx];
                let recordId = component.get("v.recordId");

                var mapUpdate = component.get("v.mapUpdate");

                var action = component.get("c.doChangeValue");
                action.setParams({
                    productId: ListData[idx].Product2Id,
                    recordId: recordId,
                    itemId : objData.Id,
                    type : type,
                    targetValue : targetValue,
                    mapUpdate : mapUpdate,
                    idx : idx
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        if(result != null){
                            component.set("v.mapUpdate", result);
                            component.set("v.isAbleClickSave", true);
                        }
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                        } else {
                            this.showToast("error", "Unknown error");
                        }
                    }
                });
                component.set("v.toggleSpinner", false);
                $A.enqueueAction(action);
                console.log('[changeValue] End ==============================>');
            },

            addRowChagneValue : function (component, event, helper, type, idx, targetValue) {
                console.log('[addRowChagneValue] Start ==============================>');
                component.set("v.toggleSpinner", true);

                let ListData = component.get("v.listData");
                let objData = ListData[idx];
                let recordId = component.get("v.recordId");

                var listUpdate = component.get("v.listUpdate");

                var action = component.get("c.doAddRowChangeValue");
                action.setParams({
                    productId: ListData[idx].Product2Id,
                    recordId: recordId,
                    itemId : objData.Id,
                    type : type,
                    targetValue : targetValue,
                    mapUpdate : mapUpdate,
                    idx : idx
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        if(result != null){
                            component.set("v.mapUpdate", result);
                            component.set("v.isAbleClickSave", true);
                        }
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                        } else {
                            this.showToast("error", "Unknown error");
                        }
                    }
                });
                component.set("v.toggleSpinner", false);
                $A.enqueueAction(action);
                console.log('[addRowChagneValue] End ==============================>');
            },

            moveRow : function (component, event, helper, idx, isUp) {
                console.log('[doMoveRow] Start ==============================>');
                component.set("v.toggleSpinner", true);

                let listData = component.get("v.listData");
                console.log('[doMoveRow] listData : ' + listData);
                let mapUpdate = component.get("v.mapUpdate");
                console.log('[doMoveRow] mapUpdate : ' + mapUpdate);
                let objData = listData[idx];
                console.log('[doMoveRow] objData : ' + objData);

                var action = component.get("c.doMoveRow");
                action.setParams({
                    mapUpdate : mapUpdate,
                    listData : listData,
                    idx : idx,
                    isUp : isUp
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('[doMoveRow] result ==============================>' + JSON.stringify(result));
                        if(result != null){
                            var listTemp = listData[idx];
                            listData[idx] = listData[idx - 1];
                            listData[idx - 1] = listTemp;
                            component.set("v.listData", listData);
                            component.set("v.mapUpdate", result);
                            component.set("v.isAbleClickSave", true);
                        }
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                        } else {
                            this.showToast("error", "Unknown error");
                        }
                    }
                });
                component.set("v.toggleSpinner", false);
                $A.enqueueAction(action);
                console.log('[doMoveRow] End ==============================>');
            },
});