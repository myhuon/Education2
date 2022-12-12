/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-08
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-08   hyunsoo.song@daeunextier.com   Initial Version
 */

({
    fnInit: function (component, event, helper) {
                component.set('v.listColumn', [
                    {label: 'Product', fieldName: 'Product2Id', type: 'lookup', editable: false, typeAttributes: {
                        required: true,
                        object : 'OpportunityLineItem',
                        fieldName : 'Product2Id',
                        value : { fieldName : 'Product2Id' },
                        context : { fieldName : 'Id' },
                        fields : ['Product2.Name'],
                        target : '_self'
                     }},
                    {label: 'ListPrice', fieldName: 'ListPrice', type: 'currency', typeAttributes: { currencyCode: 'KRW'}, editable: false},
                    {label: 'UnitPrice', fieldName: 'UnitPrice', type: 'currency', typeAttributes: { currencyCode: 'KRW'}, editable: true },
                    {label: 'Quantity', fieldName: 'Quantity', type: 'number',  editable: true, typeAttributes: { required: true } },
                    {label: 'TotalPrice', fieldName: 'TotalPrice', type: 'currency', typeAttributes: { currencyCode: 'KRW'}, editable: false },
                    {label: 'Description', fieldName: 'Description', type: 'text', editable: true},
                    {label : "Add Row", fieldName : 'Name', type: 'button', typeAttributes: {
                        label : 'Detail',
                        name    : 'detail',
                        class   : 'btn_next'
                        }
                    }
                ]);

                helper.getInitData(component);
    },

    fnSave: function(component, event, helper) {
           var draftValues = event.getParam('draftValues');
           console.log('@@@@@@@@@@@@@@@@@@ controller draftValues : ' + draftValues[0].Id);

           /*boolean isAddRow = false;
           for(OpportunityLineItem objOppItem : draftValues){
               if(objOppItem.Id == null) {
                   isAddRow = true;
                   break;
               }
           }

           if(!isAddRow){
               helper.doSaveDraftValues(component, draftValues);
           } else {
               helper.addNewItems(component, draftValues);
           }*/

           helper.doSaveDraftValues(component, draftValues);

           $A.get("e.force:refreshView").fire();
    },

    fnCancel : function(component, event, helper){
           $A.get("e.force:closeQuickAction").fire();
    },

    fnAddRow : function(component, event, helper){
        var currentData = component.get('v.listData');
        var newData = currentData.concat(
            {
                Product2Id: "", ListPrice: "", UnitPrice: "", Quantity: "", TotalPrice: "", Description: ""
            }
        );
        component.set('v.listData', newData);
    }
});