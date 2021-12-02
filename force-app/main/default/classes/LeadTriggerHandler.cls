public with sharing class LeadTriggerHandler {
    public static void createFollowUpTaskOnUpdate(List <Lead> oldLeadsList, List <Lead> newLeadsList) {
        
        //create a list of leads that will need a follow up task
        List<Lead> leadsThatNeedTasksList = new List <Lead>();
        
        //create a map of old leads to compare values
        Map <Id, Lead> oldLeadsMap= new Map <Id, Lead>();
        
        //print the size of the list to the debug log 
        system.debug('the trigger.old list has ' + oldLeadsList.size() + ' records in it');
        //if the oldLeadsList contains values..
        if(oldLeadsList.size()>0)
        {
            //put the leads into a map
            for(Lead lead:oldLeadsList){
                oldLeadsMap.put(lead.Id, lead);
            }
            
            //loop through the trigger.new leads list
            for(Lead newlead:newLeadsList){
                //print the old and new value of ProductInterest__c to the debug log
                system.debug('The new value for ProductInterest__c is ' + newLead.ProductInterest__c);
                system.debug('The old value for ProductInterest__c was ' +oldLeadsMap.get(newlead.Id).ProductInterest__c);
    
                //check whether the value of ProductInterest__c is the same as the old value
                if(newlead.ProductInterest__c!=oldLeadsMap.get(newlead.Id).ProductInterest__c){
                    //if it is, add it to the leadsThatNeedTasksList List
                    leadsThatNeedTasksList.add(newlead);

                }
            }
        } 
        else {
            //add the values from the newLeadsMap into the leadsThatNeedTasksList
            leadsThatNeedTasksList.addAll(newLeadsList);
            
        }
        
        //create a list of tasks to insert later
        List<Task> tasksToInsert = new List<Task> ();
        
        //create a SOQL for loop of leads from the leadsThatNeedTasksList that has been passed in via the trigger
        //and filter by ProductInterest__c = 'Recipe Testing'
        for (Lead lead: 
        [SELECT FirstName, LastName 
        FROM Lead 
        WHERE ProductInterest__c = 'Recipe Testing' AND Id IN: leadsThatNeedTasksList]){
            //for each record, create a new task and add it to the tasksToInsert list
            taskstoInsert.add(new Task(Subject = 'Follow up on Recipe Testing interest',
                              WhatId=lead.Id));
        }
       //insert the new tasks then print the results to the debug log
        insert tasksToInsert;
        system.debug('The new records are: '+ tasksToInsert);
    }
    
}
