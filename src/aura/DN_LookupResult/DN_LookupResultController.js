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
    doInit : function(component, event, helper) {
            var displayObject = component.get("v.object");
            var fieldName = component.get("v.fieldName");
            var secondaryFieldList = component.get("v.alternateFieldList");
            var alternateFieldValueList = [];

            component.set("v.recordDisplayName",displayObject[fieldName]);

            if(secondaryFieldList != undefined && secondaryFieldList != null && secondaryFieldList.length > 0) {
                for(var i = 0, len = secondaryFieldList.length; i < len; i++) {
                    alternateFieldValueList.push(displayObject[secondaryFieldList[i]]);
                }
            }

            component.set("v.alternateFieldValueList",alternateFieldValueList);
        }
});