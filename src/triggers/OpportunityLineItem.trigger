/**
 * @description       : 
 *                      
 * @author            : hyunsoo.song@daeunextier.com
 * @group             :
 * @last modified on  : 2022-12-21
 * @last modified by  : hyunsoo.song@daeunextier.com
 * Modifications Log
 * Ver     Date             Author               Modification
 * 1.0   2022-12-21   hyunsoo.song@daeunextier.com   Initial Version
 */
trigger OpportunityLineItem on OpportunityLineItem (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new OpportunityLineItem_tr().run();
}