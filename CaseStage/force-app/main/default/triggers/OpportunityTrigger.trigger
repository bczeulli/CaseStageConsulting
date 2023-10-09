trigger OpportunityTrigger on Opportunity (after insert, after update, before insert, before update) {

    if(Trigger.isInsert && Trigger.isBefore){
        OpportunityTriggerHandler.customerType(trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        OpportunityTriggerHandler.verifyFiles(trigger.new);
    }

}