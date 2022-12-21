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
                TableDisplayList.push('Product');
                TableDisplayList.push('ListPrice');
                TableDisplayList.push('UnitPrice');
                TableDisplayList.push('Quantity');
                TableDisplayList.push('TotalPrice');
                TableDisplayList.push('Description');
                TableDisplayList.push('');
                component.set("v.TableDisplayList", TableDisplayList);

                helper.getInitData(component, event, helper);

                component.set("v.isAbleClickAddProduct", true);
                component.set("v.isAvailableDelete", false);
                component.set("v.isClickedAddProduct", false);
                component.set("v.isAbleClickSave", false);

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
                let isUnChecked = true;
                if (idx != 'selectAll') {
                    data[idx].checked = value;
                    if(value) {
                        listSelectedData.push(data[idx]);
                    } else {
                        listSelectedData.splice(listSelectedData.indexOf(data[idx]), 1);
                    }

                    for(var row of data){
                        console.log('[fnSelectRow] row is checked?', row.checked);
                        if(row.checked){
                            isUnChecked = false;
                        }
                    }
                } else {
                    console.log('[fnSelectRow] else');
                    for(var idx = 0; idx < data.length; idx++){
                        data[idx].checked = value;
                        if(value){
                            listSelectedData.push(data[idx]);
                            isUnChecked = false;
                        } else {
                            listSelectedData.splice(listSelectedData.indexOf(data[idx]), 1);
                        }
                    }
                }
                component.set("v.listSelectedData", listSelectedData);
                component.set("v.isAvailableDelete", !isUnChecked);
                component.set("v.listData", data);
                console.log('[fnSelectRow] End =============================>');
            },

            fnAddRow: function(component, event, helper){
                console.log('[fnAddRow] Start =============================>');
                component.set("v.toggleSpinner", true);
                var validMessage = '';

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
                        'TotalPrice'             : 0.0,
                        'selectProduct'          : true
                };
                data.push(obj);
                component.set("v.listData", data);
                component.set("v.isClickedAddProduct", true);
                component.set("v.toggleSpinner", false);
                console.log('[fnAddRow] End =============================>');
            },

            fnDeleteRow: function(component, event, helper){
                console.log('[fnDeleteRow] Start =============================>');
                let listSelectedData = component.get("v.listSelectedData");
                var data = component.get("v.listData");
                var listDeleteTargetId = component.get("v.listDeleteTargetId");

                console.log('[fnDeleteRow] listSelectedData 1111=============================> ' + JSON.stringify(listSelectedData));
                for(var row of listSelectedData){
                    if(row.Id) {
                        listDeleteTargetId.push(row.Id);
                    }
                    data.splice(data.indexOf(row), 1);
                }

                if(listDeleteTargetId.length > 0) helper.deleteRow(component, event, helper, listDeleteTargetId);

                component.set("v.listData", data);
                component.set("v.listSelectedData", []);
                console.log('[fnDeleteRow] listData =============================>' + data);

                component.set("v.isAvailableDelete", false);
                console.log('[fnDeleteRow] End =============================>');
            },

            fnChangeValue: function(component, event, helper){
                console.log('[fnChangeValue] Start =============================>');
                var targetValue = event.getSource().get("v.value");
                var target = event.getSource().get("v.class").split('-');
                var type = target[1];
                var idx = parseInt(target[2],10);

                let listUpdate = component.get("v.listUpdate");

                if(listUpdate[idx] != null) {
                    helper.addRowChagneValue(component, event, helper, type, idx, targetValue);
                } else {
                    helper.changeValue(component, event, helper, type, idx, targetValue);
                }

                console.log('[fnChangeValue] End =============================>');
            },

            //DN_Lookup 으로 선택한 값
            fnHandleSelected: function(component, event, helper) {
                console.log('[fnHandleSelected] Start =============================>');
                var uniqueLookupIdentifier = event.getParam("uniqueLookupIdentifier").split('-');
                console.log('[fnHandleSelected] uniqueLookupIdentifier', uniqueLookupIdentifier);
                var productId = event.getParam("selectedId");
                console.log('[fnHandleSelected] selectedId', productId);
                if(productId.length > 0) {
                    var type = uniqueLookupIdentifier[0];
                    var idx = parseInt(uniqueLookupIdentifier[1],10);

                    //helper.changeValue(component, event, helper, type, idx, productId);
                    helper.addRowChagneValue(component, event, helper, type, idx, productId);

                    var data = component.get("v.listData");
                    data[idx].selectProduct = false;
                    component.set("v.listData", data);
                }
                console.log('[fnHandleSelected] End =============================>');
            },

            fnHandelRemoved: function(component, event, helper) {
                console.log('[fnHandelRemoved] Start =============================>');

                var uniqueLookupIdentifier = event.getParam("uniqueLookupIdentifier").split('-');
                var idx = parseInt(uniqueLookupIdentifier[1],10);
                var listData = component.get("v.listData");

                listData[idx].selectProduct = true;
                component.set("v.listData", listData);

                console.log('[fnHandelRemoved] End =============================>');
            },

            fnSave : function(component, event, helper){
                console.log('[fnSave] Start =============================>');

                var data = component.get("v.mapUpdate");
                console.log('[fnSave] mapUpdate : ' + JSON.stringify(data));
                helper.doSave(component, event, helper, data);

                console.log('[fnSave] End =============================>');
            },

            fnCancel : function(component, event, helper){
                component.set("v.toggleSpinner", true);
                $A.get('e.force:refreshView').fire();
                component.set("v.toggleSpinner", false);
                /*component.set("v.isAvailableDelete", false);
                component.set("v.isClickedAddProduct", false);
                component.set("v.isAbleClickSave", false);*/
            },

            /*fnMouseOver : function(component, event, helper){
                component.set('v.mouseOver', true);
            },

            fnMouseOut : function(component, event, helper){
                component.set('v.mouseOver', false);
            },*/

            fnMoveUp : function(component, event, helper){
                var idx = event.getSource().get("v.value");
                var listData = component.get("v.listData");
                /*var mapUpdate = component.get("v.mapUpdate");*/
                var isUp = true;

                console.log("[fnMoveUp] idx : " + idx);
/*                mapUpdate[index].sortOrder -= 1;
                mapUpdate[index - 1].sortOrder += 1;
                component.set("v.mapUpdate", mapUpdate);*/

                /*listData[index].sortOrder -= 1;
                listData[index - 1].sortOrder += 1;
                component.set("v.listData", listData);*/

                // 화면에서 row ▲ 누름과 동시에 움직이기 위해서 switch (실제 레코드 sortOrder는 저장 버튼 클릭 시 변경됨)

                helper.moveRow(component, event, helper, idx, isUp);



                // 저장 버튼 클릭 시 실제 데이터 switch
               /* var mapTemp = mapUpdate[index];

                if(mapUpdate[index-1] != null) {
                    mapUpdate[index] = mapUpdate[index - 1];
                } else {
                    mapUpdate[index] = listData[index];
                }

                if(mapTemp != null) {
                    mapUpdate[index - 1] = mapTemp;
                } else {
                    mapUpdate[index - 1] = listData[index - 1];
                }

                console.log('[fnMoveUp] mapUpdate : ' + JSON.stringify(mapUpdate));
                component.set("v.mapUpdate", mapUpdate);
                component.set("v.isAbleClickSave", true);*/
            },

            fnMoveDown : function(component, event, helper){
                var index = event.getSource().get("v.value");
                var listData = component.get("v.listData");

                // value switch
                var temp = listData[index];
                listData[index] = listData[index + 1];
                listData[index + 1] = temp;

                component.set("v.listData", listData);
                component.set("v.isAbleClickSave", true);
            }
});