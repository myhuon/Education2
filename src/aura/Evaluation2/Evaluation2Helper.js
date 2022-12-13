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
                //var objOrder = component.get("v.objOrder");
                var action = component.get("c.saveRecord");

                action.setParams({
                    draftValues : draftValues
                });

                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.listUpdate", []);
                        this.doChangeTotal(component, event, helper);
                        helper.showToast("success", "Save Success!");
                        console.log('[doSave] SUCCESS!!! ==============================>');
                        $A.get('e.force:refreshView').fire();
                        //helper.getInitData(component, event, helper);
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
                var listUpdate = component.get("v.listUpdate");
                /*var objOrder = component.get("v.objOrder");
                console.log('[changeValue] objOrder : ', objOrder);*/
                console.log('[changeValue] before changed', objData);
                //let qty = ((objData.Quantity !== undefined || objData.Quantity !== null) && objData.Quantity instanceof String) ? parseFloat(objData.Quantity) : objData.Quantity;
                //let objPricebook = component.get("v.listPricebookEntry")
                //switch (type) {
                    //case 'Amount':
                    var targetField = '';
                    switch (type) {
                        case 'Amount':
                            targetField = 'qty';
                            break;
                        case 'Price':
                            targetField = 'unitprice';
                            break;
                        case 'Description':
                            targetField = 'description';
                            break;
                    }

                        console.log('[changeValue] Amount');
                        if(!$A.util.isEmpty(targetValue)){
                           //objData.Quantity = parseFloat(targetValue);
                           // if (objOrder.fm_DEAL_TYPE__c != undefined) {
                                component.set("v.listData", ListData);
                                component.set("v.toggleSpinner", true);

                                var action = component.get("c.getResourcePrice");
                                action.setParams({
                                    productId: ListData[idx].Product2Id,
                                    recordId: component.get("v.recordId"),
                                    itemId : objData.Id,
                                    targetField : targetField,
                                    targetValue : targetValue
                                });
                                action.setCallback(this, function (response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        var result = response.getReturnValue();
                                        console.log('[changeValue] result', result);
                                        if(result != null){
                                            console.log('[doSave] listUpdate1 : ', listUpdate);
                                            listUpdate.push(result);
                                            console.log('[doSave] listUpdate2 : ', listUpdate);
                                            component.set("v.listUpdate", listUpdate);
                                            console.log('[doSave] listUpdate3 : ', listUpdate);
                                        }
                                        /*if(!$A.util.isEmpty(result['objPricebookByItem'].ListPrice)) {
                                            objData.ListPrice__c = result['objPricebookByItem'].ListPrice;
                                            if(objData.DC__c != 0 && !$A.util.isEmpty(objData.UnitPrice)) {
                                                if (objData.AdditionalDiscount__c != 0) {
                                                    objData.UnitPrice = objData.ListPrice__c * ((100 - objData.DC__c) * 0.01);
                                                    objData.DiscountAmount__c = objData.ListPrice__c * (objData.DC__c * 0.01) * targetValue;
                                                    objData.TotalPrice__c = objData.UnitPrice * targetValue;
                                                } else {
                                                    objData.DC__c = (100 - ((objData.UnitPrice / objData.ListPrice__c) * 100));
                                                    objData.DiscountAmount__c = objData.ListPrice__c * (objData.DC__c * 0.01) * targetValue;
                                                    objData.TotalPrice__c = objData.UnitPrice * targetValue;
                                                }
                                            } else {
                                                objData.UnitPrice = objData.ListPrice__c;
                                                objData.AdditionalDiscount__c = 0.0;
                                                objData.DC__c = 0.0;
                                                objData.TotalPrice__c = objData.Quantity * objData.UnitPrice;
                                            }
                                        }*/
                                        /*if(!$A.util.isEmpty(result['objPricebookByItem'].ListPrice)) {
                                            objData.ListPrice__c = result['objPricebookByItem'].ListPrice;
                                            objData.UnitPrice = result['objPricebookByItem'].ListPrice;
                                        }
                                        objData.TotalPrice__c = objData.Quantity * objData.UnitPrice;
                                        objData.DiscountAmount__c = 0.0;
                                        objData.AdditionalDiscount__c = 0.0;
                                        objData.DC__c = 0.0;*/
                                        console.log('[changeValue] result of changed', JSON.stringify(objData));
                                        //component.set("v.listData", ListData);

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
                          //  }
                        }
                   // break;
                //}
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