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
                    key: "info_alt"
                    , type: type
                    , message: message
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
                            this.doChangeTotal(component, event, helper);
                            his.doSetDisability(component, event, helper);
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
                this.doChangeTotal(component, event, helper);

                var action = component.get("c.saveRecord");

                action.setParams({
                    draftValues : draftValues
                });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.listUpdate", []);
                        component.set("v.mapUpdate", {});
                        console.log("%%%%%%%%%%%%%%% : ", component.get("v.listUpdate"));
                        this.doChangeTotal(component, event, helper);
                        helper.showToast("success", "Save Success!");
                        console.log('[doSave] SUCCESS!!! ==============================>');
                        $A.get('e.force:refreshView').fire();
                        //helper.getInitData(component, event, helper);
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            this.showToast("error", $A.get("$Label.c.isEmptyRequiredField"));
                        } else {
                            this.showToast("error", "Unknown error");
                        }
                    }

                    component.set("v.toggleSpinner", false);
                });
                $A.enqueueAction(action);
                console.log('[doSave] End ==============================>');
            },

            deleteRow: function (component, event, helper, listDeleteTargetId) {
                console.log('[deleteRow] Start ==============================>');
                component.set("v.toggleSpinner", true);
                var action = component.get("c.deleteRecord");
                action.setParams({
                    strDeleteTargetId: (listDeleteTargetId.length > 0) ? JSON.stringify(listDeleteTargetId) : ''
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
                        //this.getInitData(component, event, helper);
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
                console.log('[changeValue] type : ', type);
                console.log('[changeValue] idx : ', idx);
                console.log('[changeValue] targetValue : ', targetValue);

                let ListData = component.get("v.listData");
                let objData = ListData[idx];
                let recordId = component.get("v.recordId");
                var listUpdate = component.get("v.listUpdate");
                var mapUpdate = component.get("v.mapUpdate");
                console.log('[changeValue] before changed', objData);

                if(!$A.util.isEmpty(targetValue)){
                    component.set("v.listData", ListData);
                    component.set("v.toggleSpinner", true);

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
                            console.log('[changeValue] result', result);
                            if(result != null){
                                console.log('[changeValue] listUpdate2 : ', mapUpdate);
                                component.set("v.mapUpdate", result);
                                console.log('[changeValue] listUpdate3 : ', JSON.stringify(mapUpdate));
                            }
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
                }
                component.set("v.toggleSpinner", false);
                console.log('[changeValue] End ==============================>');
            },

            doChangeTotal : function (component, event, helper) {
                console.log('[doChangeTotal] Start ==============================>');
                let ListData = component.get("v.listData");

                let TotalQuantityAllProduct = 0.0;      //수량 합계
                let TotalPriceAllProduct = 0.0;         //금액 합계
                let DiscountAmountAllProduct = 0.0;     //할인금액 합계
                let DiscountedRateAllProduct = 0.0;     //할인총계

                let ListPriceAmountTotal = 0.0;         //할인총계 계산을 위한 (표준단가) 총계
                let TotalPriceAmountTotal = 0.0;        //할인총계 계산을 위한 (수주단가 * 수량) 총계

                for (var i = 0; i < ListData.length; i++){
                    TotalPriceAllProduct +=  parseFloat(ListData[i].TotalPrice);
                    if (!this.isNullCheck(ListData[i].Product2Id)) {
                        TotalQuantityAllProduct +=  parseFloat(ListData[i].Quantity);
                        TotalPriceAmountTotal +=  parseFloat(ListData[i].TotalPrice);
                        ListPriceAmountTotal +=  parseFloat(ListData[i].ListPrice * ListData[i].Quantity);
                    }
                }

                component.set("v.TotalQuantityAllProduct", isNaN(TotalQuantityAllProduct) ? 0 : TotalQuantityAllProduct);
                component.set("v.TotalPriceAllProduct", isNaN(TotalPriceAllProduct) ? 0 : TotalPriceAllProduct);
                component.set("v.DiscountAmountAllProduct", isNaN(DiscountAmountAllProduct) ? 0 : DiscountAmountAllProduct);
                DiscountedRateAllProduct = parseFloat(((ListPriceAmountTotal - TotalPriceAmountTotal) / ListPriceAmountTotal));
                component.set("v.DiscountedRateAllProduct", isNaN(DiscountedRateAllProduct) ? 0 : DiscountedRateAllProduct);

                console.log('[doChangeTotal] 수량 합계(Quantity 의 합) =========> ' + TotalQuantityAllProduct);
                console.log('[doChangeTotal] 금액 합계(TotalPrice__c 의 합) =========> ' + TotalPriceAllProduct);
                console.log('[doChangeTotal] 할인금액 합계(DiscountAmount__c 의 합) =========> ' + DiscountAmountAllProduct);
                console.log('[doChangeTotal] 할인총계 계산을 위한 (표준단가 * 수량) 총계 A    =========> ' + ListPriceAmountTotal);
                console.log('[doChangeTotal] 할인총계 계산을 위한 (수주단가 * 수량) 총계 B   =========> ' + TotalPriceAmountTotal);
                console.log('[doChangeTotal] 할인총계 = (총계 A - 총계 B)/총계 A    =========> ' + parseFloat(((ListPriceAmountTotal - TotalPriceAmountTotal) / ListPriceAmountTotal)));
                console.log('[doChangeTotal] End ==============================>');
            },

});