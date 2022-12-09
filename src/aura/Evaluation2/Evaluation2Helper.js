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
    getInitData : function(component) {
        component.set("v.toggleSpinner", true);
        var action = component.get("c.getInitData");

        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set('v.listData', returnValue);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    doSaveDraftValues : function (component, event, draftValues) {
        var action = component.get("c.updateRecord");

        action.setParams({
            draftValues : draftValues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('################# update Result : ' + updateResult);
            if(state === "SUCCESS") {
                var updateResult = response.getReturnValue();

                if(updateResult){
                    this.showToast("Success", "Update Success");
                } else {
                    this.showToast("Error", "Update Fail");
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    addNewItems : function(component, draftValues) {
        var action = component.get("c.createRecord");

        action.setParams({
            draftValues : draftValues
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var createResult = response.getReturnValue();

                if(createResult){
                    this.showToast("Success", "Create Success");
                } else {
                    this.showToast("Error", "Create Fail");
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
                if(errors) {
                    if(errors[0] && errors[0].message) this.showToast("error", errors[0].message);
                } else {
                    this.showToast("error", "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt",
            type : type,
            message : message
        });
        evt.fire();
    }

/*
     saveEdition: function (cmp, draftValues) {
                        var self = this;
                        // simulates a call to the server, similar to an apex controller.
                        this
                            .server
                            .updateOpportunities(draftValues)
                            .then($A.getCallback(function (response) {
                                var state = response.state;

                                if (state === "SUCCESS") {
                                    var returnValue = response.returnValue;

                                    if (Object.keys(returnValue.errors).length > 0) {
                                        // the draft values have some errors, setting them will show it on the table
                                        cmp.set('v.errors', returnValue.errors);
                                    } else {
                                        // Yay! success, initialize everything back
                                        cmp.set('v.errors', []);
                                        cmp.set('v.draftValues', []);
                                        self.getInitData(cmp);
                                    }
                                } else if (state === "ERROR") {
                                    var errors = response.error;
                                    console.error(errors);
                                }
                            }));
                    },
                    // Helpers to simulate a server.
                    /!*initServer: function () {
                        // used only to simulate a server where you make requests.
                        self = this;

                        var serverReady = new Promise(function (resolve, reject) {
                            self
                                ._generateData()
                                .then(function (generatedData) {
                                    self.server._dataMap = generatedData.reduce(function (accumulator, opportunity) {
                                        opportunity.closeDate = opportunity.closeDate.toISOString();
                                        accumulator[opportunity.id] = opportunity;

                                        return accumulator;
                                    }, {});
                                    resolve(true);
                                });
                        });

                        return serverReady;

                    },*!/
                    server: {
                        _dataMap: {},
                        getOpportunityLineItems : function () {
                            var self = this;
                            var dataPromise = new Promise(function (resolve) {
                                resolve({
                                    state: "SUCCESS",
                                    returnValue: Object.values(self._dataMap)
                                });
                            });

                            return dataPromise;
                        },
                        updateOpportunities: function (draftOpportunities) {
                            var self = this;
                            var updatePromise = new Promise(function (resolve) {
                                var response = {
                                    state: "SUCCESS",
                                    returnValue: {}
                                };

                                response.returnValue.errors = self._validateOpportunities(draftOpportunities);

                                if (Object.keys(response.returnValue.errors).length > 0) {
                                    response.code = 'EDITION_HAS_ERRORS';
                                } else {
                                    self._saveDraftOpportunities(draftOpportunities);
                                }

                                resolve(response);
                            });

                            return updatePromise;
                        },
                        _saveDraftOpportunities: function (opportunities) {
                            var self = this;
                            opportunities.forEach(function (opportunity) {
                                var storedOpportunity = self._dataMap[opportunity.id];
                                self._dataMap[opportunity.id] = Object.assign(
                                    {},
                                    storedOpportunity,
                                    opportunity
                                );
                            });
                        },
                        _validateOpportunities: function (opportunities) {
                            var self = this;
                            var totalErrors = 0;
                            var errors = {};// new Map<String, Object>();
                            var rowsError = {};// new Map<String, Object>();

                            opportunities.forEach(function (opportunity) {
                                var rowErrorMessages = [];
                                var rowErrorFieldNames = [];

                                if (opportunity.confidence && (opportunity.confidence < 0 || opportunity.confidence > 1)) {
                                    rowErrorMessages.push('The confidence should be a value between 0 (0%) and 1 (100%).');
                                    rowErrorFieldNames.push('confidence');
                                }

                                if (opportunity.amount && opportunity.amount < 0) {
                                    rowErrorMessages.push('The amount should be greater than 0.');
                                    rowErrorFieldNames.push('amount');
                                }

                                if (rowErrorMessages.length > 0) {
                                    var storedOpportunity = self._dataMap[opportunity.id];

                                    totalErrors += rowErrorMessages.length;

                                    rowsError[opportunity.id] = {
                                        messages: rowErrorMessages,
                                        fieldNames: rowErrorFieldNames,
                                        title: storedOpportunity.opportunityName + ' has ' + rowErrorMessages.length + ' error(s)'
                                    };
                                }
                            });

                            if (totalErrors > 0) {
                                var tableMessages = [];// new List<String>();


                                var rowErrorValues = Object.values(rowsError);
                                rowErrorValues.forEach(function (rowError) {
                                    tableMessages.push(rowError.title);
                                });


                                errors = {
                                    /!**
                                     * Information to be displayed on each row that has an edition with an error.
                                     * This is an object in the form:
                                     * {
                                     *      'row-id': {
                                     *          // displayed in the help text of the icon in the row with id "row-id" indicating that the edition has error(s)
                                     *          title: 'Error title',
                                     *          // an array of messages
                                     *          messages: [],
                                     *          // an array of field names to which message corresponds
                                     *          fieldNames: [],
                                     *      }
                                     * }
                                     *!/
                                    rows: rowsError,
                                    table: { // displayed at the end of the table
                                        title : 'Some records have errors', // the title of the popover
                                        messages : tableMessages // A list of messages to be displayed as the popover content
                                    }
                                };
                            }

                            return errors;
                        }
                    },
                    _generateData: function () {
                        var schema = {
                            opportunityName: 'company.companyName',
                            closeDate: 'date.future',
                            amount: 'finance.amount',
                            contact: 'internet.email',
                            phone: 'phone.phoneNumber',
                            website: 'internet.url',
                            status: {type: 'helpers.randomize', values: ['Pending', 'Approved', 'Complete', 'Closed']}
                        };

                        schema.confidence = {
                            type: function () {
                                return Math.random().toFixed(2);
                            }
                        };

                        //return this.mockdataLibrary.lightningMockDataFaker(schema, 15);
                    }*/
});