/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-13
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-13   hyunsoo.song@daeunextier.com   Initial Version
 */
trigger Opportunity on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Opportunity_tr().run();
}