trigger LeadTrigger on Lead (after insert, after update) {
    LeadTriggerHandler.createFollowUpTaskOnUpdate(Trigger.old, Trigger.new);

}