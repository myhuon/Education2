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
    fnInit : function(component, event, helper) {
            var header = component.get("v.header");
            var data = component.get("v.data");

            var typeOfHeader = typeof header;
            if(typeOfHeader === "object") {
                component.set("v.columnValue", data[header.fieldName]);
                component.set("v.headerType", header.type);
            } else {
                component.set("v.columnValue", data[header]);
                component.set("v.headerType", "STRING");
            }
        }
});