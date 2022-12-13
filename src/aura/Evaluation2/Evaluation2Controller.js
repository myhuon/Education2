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
    fnInit : function(component, event, helper){
                //Table Column 값을 Custom Label로 지정
                component.set("v.toggleSpinner", true);

                let TableDisplayList = [];
                /*TableDisplayList.push('Seq');*/
                TableDisplayList.push('Product');
                TableDisplayList.push('ListPrice');
                TableDisplayList.push('UnitPrice');
                TableDisplayList.push('Quantity');
                TableDisplayList.push('TotalPrice');
                TableDisplayList.push('Description');
                component.set("v.TableDisplayList", TableDisplayList);

                helper.getInitData(component, event, helper);
                component.set("v.isAbleClickAddProduct", true);
                component.set("v.toggleSpinner", false);
    },

            // SpecSheetList 레코드 선택
            fnSelectRow: function(component, event){
                console.log('[fnSelectRow] Start =============================>');
                var idx = event.getSource().get("v.name");
                console.log('[fnSelectRow] idx =============================>' + idx);
                var value = event.getSource().get("v.checked");
                console.log('[fnSelectRow] value =============================>' + value);
                var data = component.get("v.listData");
                console.log('[fnSelectRow] data =============================>' + data);
                let listSelectedData = component.get("v.listSelectedData");

                //data.forEach(function(pl){ pl.checked = false; });
                if (idx != 'selectAll') {
                    //data.forEach(pl => pl.checked = false);
                    data[idx].checked = value;
                    if(value) {
                        listSelectedData.push(data[idx]);
                    } else {
                        listSelectedData.splice(listSelectedData.indexOf(data[idx]), 1);
                    }
                    //component.set("v.dataIdx", idx);
                    component.set("v.listSelectedData", listSelectedData);
                    component.set("v.listData", data);

                    let isUnChecked = true;
                    for(var row of data){
                        console.log('[fnSelectRow] row is checked?', row.checked);
                        if(row.checked){
                            isUnChecked = false;
                        }
                    }
                    component.set("v.isAvailableDelete", !isUnChecked);
                } else {
                    console.log('[fnSelectRow] else');
                    let isUnChecked = true;
                    for(var idx = 0; idx < data.length; idx++){
                        data[idx].checked = value;
                        if(value){
                            listSelectedData.push(data[idx]);
                            isUnChecked = false;
                        } else {
                            listSelectedData.splice(listSelectedData.indexOf(data[idx]), 1);
                        }
                    }
                    component.set("v.listSelectedData", listSelectedData);
                    component.set("v.isAvailableDelete", !isUnChecked);
                    component.set("v.listData", data);
                }
                console.log('[fnSelectRow] End =============================>');
            },

            fnAddRow: function(component, event, helper){
                console.log('[fnAddRow] Start =============================>');
                component.set("v.toggleSpinner", true);
                var validMessage = '';
                var objOrder = component.get("v.objOrder");
                var hasShippingFee = component.get("v.hasShippingFee");

                if(validMessage != '') {
                    component.set("v.toggleSpinner", false);
                    helper.showToast('info', validMessage);
                    return;
                }
                var data = component.get("v.listData");
                let obj = {
                        'sobjectType'            :'OpportunityLineItem',
                        'Product2Id'             : null,
                        'OpportunityId'          : component.get("v.recordId"),
                        'ListPrice'              : 0.0,
                        'UnitPrice'              : 0.0,
                        'Quantity'               : 0.0,
                        'checked'                : false,
                        'TotalPrice'             : 0.0
                };
                data.push(obj);
                console.log('[fnAddRow] add row info', obj);
                component.set("v.listData", data);
                component.set("v.toggleSpinner", false);
                console.log('[fnAddRow] End =============================>');
            },

            fnDeleteRow: function(component, event, helper){
                console.log('[fnDeleteRow] Start =============================>');
                //var idx = parseInt(event.getSource().get("v.name"));
                let listSelectedData = component.get("v.listSelectedData");
                var data = component.get("v.listData");
                var listDeleteTargetId = component.get("v.listDeleteTargetId");


                console.log('[fnDeleteRow] listSelectedData 1111=============================> ' + JSON.stringify(listSelectedData));
                for(var row of listSelectedData){
                    if(row.Id) {
                        listDeleteTargetId.push({Id : row.Id});
                    }
                    data.splice(data.indexOf(row), 1);
                }
                console.log('[fnDeleteRow] listDeleteTargetId =============================>' + JSON.stringify(listDeleteTargetId));

        /*        if(data[idx].Id) {
                    listDeleteTargetId.push({Id : data[idx].Id});
                }
                data.splice(idx,1);*/

                if(listDeleteTargetId.length > 0)
                    helper.deleteRow(component, event, helper, listDeleteTargetId);

                component.set("v.listData", data);
                component.set("v.listSelectedData", []);
                console.log('[fnDeleteRow] listData =============================>' + data);

                helper.doChangeTotal(component, event, helper);
                component.set("v.isAvailableDelete", false);
                console.log('[fnDeleteRow] End =============================>');
            },

            fnChangeValue: function(component, event, helper){
                console.log('[fnChangeValue] Start =============================>');
                var targetValue = event.getSource().get("v.value");
                console.log('[fnChangeValue] targetValue =========> '+targetValue);
                if(targetValue.length > 0){
                    var target = event.getSource().get("v.class").split('-');
                    console.log('[fnChangeValue] v.class', event.getSource().get("v.class"));
                    console.log('[fnChangeValue] target', target);
                    var type = target[1];
                    var idx = parseInt(target[2],10);

                    helper.changeValue(component, event, helper, type, idx, targetValue);
                } else {
                    var target = event.getSource().get("v.class").split('-');
                    console.log('[fnChangeValue] target is null', target);
                    var type = target[1];
                    var idx = parseInt(target[2],10);

                    helper.changeValue(component, event, helper, type, idx, targetValue);
                }
                console.log('[fnChangeValue] End =============================>');
            },

            //DN_Lookup 으로 선택한 값
            fnHandleSelected: function(component, event, helper) {
                console.log('[fnHandleSelected] Start =============================>');
                var uniqueLookupIdentifier = event.getParam("uniqueLookupIdentifier").split('-');
                console.log('[fnHandleSelected] uniqueLookupIdentifier', uniqueLookupIdentifier);
                var targetValue = event.getParam("selectedId");
                console.log('[fnHandleSelected] selectedId', targetValue);
                if(targetValue.length > 0){
                    var type = uniqueLookupIdentifier[0];
                    var idx = parseInt(uniqueLookupIdentifier[1],10);

                    helper.changeValue(component, event, helper, type, idx, targetValue);
                }
                console.log('[fnHandleSelected] End =============================>');
            },

            fnHandelRemoved: function(component, event, helper) {
                console.log('[fnHandelRemoved] Start =============================>');
                var uniqueLookupIdentifier = event.getParam("uniqueLookupIdentifier").split('-');
                var targetValue = event.getParam("selectedId");
                var type = uniqueLookupIdentifier[0];
                var idx = parseInt(uniqueLookupIdentifier[1],10);
                var listData = component.get("v.listData");
                var objData = listData[idx];
                console.log('[fnHandelRemoved] uniqueLookupIdentifier', uniqueLookupIdentifier);
                console.log('[fnHandelRemoved] selectedId', targetValue);
                console.log('[fnHandelRemoved] type', type);
                console.log('[fnHandelRemoved] idx', idx);
                console.log('[fnHandelRemoved] objData', objData);
                switch (type) {
                    case 'PricebookEntry' :
                        objData.Description__c = null;
                        objData.Product = null;
                        objData.UnitPrice = 0.0;
                        objData.ListPrice = 0.0;
                        objData.TotalPrice = 0.0;
                        objData.Quantity = 0.0;
                        objData.PricebookEntryId = null;
                        break;
                }
                component.set("v.listData", listData);
                console.log('[fnHandelRemoved] End =============================>');
            },

            fnSave: function(component, event, helper){
                console.log('[fnSave] Start =============================>');
                component.set("v.toggleSpinner", true);
                var validMessage = '';
                //var data = component.get("v.listData");
                var data = component.get("v.listUpdate");
                console.log('[fnSave] v.listUpdate : ', data);

                if(validMessage != '') {
                    component.set("v.toggleSpinner", false);
                    helper.showToast('info', validMessage);
                    return;
                }
                helper.doSave(component, event, helper, data);
                console.log('[fnSave] End =============================>');
            },

            fnMouseOver : function(component, event, helper){
                component.set('v.mouseOver', true);
            },

            fnMouseOut : function(component, event, helper){
                component.set('v.mouseOver', false);
            }
});