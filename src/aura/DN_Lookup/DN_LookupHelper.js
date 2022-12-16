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
 /**
  * Created by 천유정 on 2022-08-17.
  */

({
    // 만들어진 쿼리로 레코드 조회
    doQueryRecords : function(component) {
        var action = component.get('c.querySalesforceRecord');
        action.setParams({queryString : component.get('v.query')});
        action.setCallback(this, function(response){
            var responseState = response.getState();
            if(responseState === 'SUCCESS') {
                component.set('v.objectList',response.getReturnValue());
                component.set('v.selectedIndex',undefined);
                component.set('v.searching',false);
                component.set('v.lookupInputFocused',true);
            }else {
                component.set('v.queryErrorMessage',response.getError()[0].message);
                component.set('v.queryErrorFound',true);
                component.set('v.objectList',[]);
                component.set('v.selectedIndex',undefined);
                component.set('v.searching',false);
                console.log('error',response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
    },

    onValueselect : function(component, selectedObject, selectedObjectIndex) {
        console.log('--------------------------------------------------     DN_Lookup.helper.onValueselect - start');
        console.log('@@@ selectedObjectIndex @@@');
        console.log(selectedObjectIndex);
        if(!selectedObject || selectedObjectIndex == undefined) {
            return false;
        } else {
            var primaryDisplayField = component.get('v.primaryDisplayField');

            if(component.get('v.multiSelect')) {
                var listSelectedOptions = component.get('v.listSelectedOptions');
                var listSelectedObject = component.get('v.selectedObject');
                if(!listSelectedObject) listSelectedObject = [];

                // 중복 선택 검사
                var isValid = true;
                for(var i in listSelectedObject) {
                    var obj = listSelectedObject[i];
                    if(obj.Id == selectedObject.Id) {
                        isValid = false;
                        this.showToast('error', '중복 선택 하셨습니다.');
                        break;
                    }
                }

                if(!isValid) return;

                // 유효성 검사 통과
                var listLookupIds = component.get('v.listLookupIds');

                listLookupIds.push(selectedObject.Id);
                listSelectedObject.push(selectedObject);
                listSelectedOptions.push(selectedObject[primaryDisplayField]);

                component.set('v.selectedObject', listSelectedObject);
                component.set('v.listSelectedOptions', listSelectedOptions);
                component.set('v.selectedId', listLookupIds.join(';'));
                component.set('v.listLookupIds', listLookupIds);
            } else {
                component.set('v.selectedObject',selectedObject);
                component.set('v.selectedLabel',selectedObject[primaryDisplayField]);
                component.set('v.selectedId',selectedObject['Id']);
                component.set('v.lookupInputFocused',false);
            }
            component.set('v.enteredValue','');

            console.log('[onValueSelect] uniqueLookupIdentifier : ' + component.get('v.uniqueLookupIdentifier'));
            console.log('[onValueSelect] selectedId : ' + component.get('v.selectedId'));
            console.log('[onValueSelect] selectedLabel : ' + component.get('v.selectedLabel'));
            console.log('[onValueSelect] selectedObject : ' + component.get('v.selectedObject'));

            var lookupSelectedEvent = component.getEvent('lookupSelected');
                lookupSelectedEvent.setParams({
                    'uniqueLookupIdentifier' : component.get('v.uniqueLookupIdentifier'),
                    'selectedId' : component.get('v.selectedId'),
                    'selectedLabel' : component.get('v.selectedLabel'),
                    'selectedObject' : component.get('v.selectedObject')
                });
            lookupSelectedEvent.fire();

            return true;
        }
    },

    doRemoveOption : function(component, event) {
        console.log('--------------------------------------------------     DN_Lookup.doRemoveOption - start');

        var listSelectedObject = component.get('v.selectedObject');
        var selectedObject = JSON.stringify(component.get('v.selectedObject'));

		var selectedObjectIndex = component.get('v.selectedIndex');

		console.log('@@@ selectedObjectIndex @@@');
		console.log(selectedObjectIndex);

		if(selectedObjectIndex == undefined) {
		    //return false;
		}

        if(component.get('v.multiSelect')) {

            var idx = event.currentTarget.dataset.idx;
            var listSelectedOptions = component.get('v.listSelectedOptions');
            var listLookupIds = component.get('v.listLookupIds');

            listLookupIds.splice(idx, 1);
            listSelectedObject.splice(idx, 1);
            listSelectedOptions.splice(idx, 1);

            component.set('v.listSelectedOptions', listSelectedOptions);
            component.set('v.selectedObject', listSelectedObject);
            component.set('v.selectedId', (listLookupIds.join(';') === '' ? undefined : listLookupIds.join(';')));
        } else {
            component.set('v.selectedObject',undefined);
            component.set('v.selectedLabel','');
            component.set('v.selectedId',undefined);
        }

        component.set('v.enteredValue', '');

        var selectedLookupRemoved = component.getEvent('selectedLookupRemoved');
        selectedLookupRemoved.setParams({
            'uniqueLookupIdentifier' : component.get('v.uniqueLookupIdentifier'),
            'selectedId' : component.get('v.selectedId'),
            'selectedLabel' : component.get('v.selectedLabel'),
            'selectedObject' : component.get('v.selectedObject')
        });
        selectedLookupRemoved.fire();
    },

    getLookupDatas : function(component, query) {
        var action;
        var isFirst = (component.get('v.tableColumns').length <= 0);

        if(isFirst) {
            action = component.get('c.getLookupDatas');
            action.setParams({
                query : query,
                sObjectName : component.get('v.objectName'),
                fieldSet : component.get('v.fieldSet')
            });
        } else {
            action = component.get('c.querySalesforceRecord');
            action.setParams({
                queryString : query
            });
        }

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var result = response.getReturnValue();

                if(isFirst) {
                    component.set('v.tableColumns', result.listColumns);
                    component.set('v.tableDatas', result.listDatas);
                } else {
                    component.set('v.tableDatas', result);
                }

                var dataLength = component.get('v.tableDatas').length;

                component.set('v.pageNumber', 1);
                component.set('v.total', dataLength);
                component.set('v.pages', Math.ceil(dataLength / 15));
                component.set('v.maxPage', Math.floor((dataLength + 19) / 20));

                this.doRenderPage(component);
            }
        });

        $A.enqueueAction(action);
    },

    doRenderPage: function(component) {
        var tableDatas = component.get('v.tableDatas');
        var pageNumber = component.get('v.pageNumber');
        var pageRecords = tableDatas.slice((pageNumber - 1) * 20, pageNumber * 20);

        component.set('v.pagingDatas', pageRecords);
        component.set('v.isShowSpinner', false);
        component.find('searchKey').focus();
    },

    // 레코드 검색 결과 모달
    doOpenModal : function(component) {
        // 메인 페이지 scroll 방지
        document.body.style.overflow = 'hidden';
        component.set('v.isOpenModal', true);
        component.set('v.isShowSpinner', true);
        component.find('searchKey').set('v.value', component.get('v.enteredValue'));

        this.getLookupDatas(component, component.get('v.query'));
    },
    doCloseModal : function(component) {
        // 메인 페이지 scroll 방지 해제
        document.body.style.overflow = 'auto';
        component.set('v.isOpenModal', false);
        component.set('v.isShowSpinner', false);
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");

        evt.setParams({
            key     : "info_alt",
            type    : type,
            message : message
        });

        evt.fire();
    },

    getInitLookupDatas : function(component, query) {
        console.log('[getInitLookupDatas] start -------------> ');
            var action;
            var isFirst = (component.get('v.tableColumns').length <= 0);

            if(isFirst) {
                action = component.get('c.getLookupDatas');
                action.setParams({
                    query : query,
                    sObjectName : component.get('v.objectName'),
                    fieldSet : component.get('v.fieldSet')
                });
            } else {
                action = component.get('c.querySalesforceRecord');
                action.setParams({
                    queryString : query
                });
            }

            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS') {
                    var result = response.getReturnValue();

                    if(isFirst) {
                        component.set('v.tableColumns', result.listColumns);
                        component.set('v.tableDatas', result.listDatas);
                    } else {
                        component.set('v.objectList', result);
                    }

                    console.log('[getInitLookupDatas] result : ' + result);
                    var dataLength = component.get('v.objectList').length;

                    component.set('v.pageNumber', 1);
                    component.set('v.total', dataLength);
                    component.set('v.pages', Math.ceil(dataLength / 15));
                    component.set('v.maxPage', Math.floor((dataLength + 19) / 20));

                    this.doRenderPage(component);
                }
            });

            console.log('[getInitLookupDatas] end -------------> ');
            $A.enqueueAction(action);
        },
})
