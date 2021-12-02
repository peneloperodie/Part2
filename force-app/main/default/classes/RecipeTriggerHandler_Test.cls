@isTest
private class RecipeTriggerHandler_Test {
    //first load some test data
    @TestSetup
    static void loadTestData(){
        List<Recipe__c> recipes = Test.loadData(Recipe__c.SObjectType, 'Recipes');
        List <Cookbook__c> cookbooks = Test.loadData (Cookbook__c.SObjectType, 'Cookbooks');  
        
    }

    
    @isTest static void checkKeyValuesDraftOnInsert() {
        //create a variable to hold the exception message
        Test.startTest();
        String exceptionMessage;
        //create a recipe record to attempt to insert
        Recipe__c newRecipe = new Recipe__c();
        newRecipe.Name='new Recipe name';
        try{
            insert newRecipe;
           }
        catch(Exception e){
            exceptionMessage=e.getMessage(); 
            System.debug('This is the exception message: ' +exceptionMessage);
        }
        Test.stopTest();
        //Assert that an error has been thrown
        System.assert(exceptionMessage.contains('This recipe needs to have values in name, active time, description, active time units and servings'), 'Expected an exception message about values being missing from the recipe record');
        
         }
    
    /*@isTest static void checkKeyValuesDraftOnUpdate(){
     //create a string variable to hold the exception message
     String exceptionMessage;
     //find 1 recipe that has all key values completed and delete the name value for that record  
        try{
            Recipe__c currentRecipe= [SELECT Id, Name, Active_Time__c, Active_Time_Units__c, Description__c, Servings__c, Draft__c 
                                       FROM Recipe__c 
                                       WHERE Name!=NULL AND Active_Time__c!=NULL AND Active_Time_Units__c!=NULL AND Description__c!=NULL AND Servings__c!=NULL 
                                       LIMIT 1];
            currentRecipe.Name=NULL;
            update currentRecipe;
            }
        
        catch(Exception e){
          exceptionMessage=e.getMessage();
        }
        //assert that the error message is the expected one about values being missing
       System.assert(exceptionMessage=='This recipe needs to have values in name, active time, description, active time units and servings', 'Expected an exception message about values being missing from the recipe record');
        
    }*/
    
    @isTest static void checkRecipeComplexityOnInsert(){
    //insert a recipe and check its complexity - the insert has happened by loading the data from static resource
    
    //find all the recipes in the database
    List<Recipe__c> recipes = [SELECT Id, Name, Active_Time__c, Active_Time_Units__c, Servings__c, Complexity__c FROM Recipe__c];
    
        //loop through them 
        for(Recipe__c currentRecipe: recipes){
            
            // If the recipe has an active time of an hour or more, the complexity should be difficult
            if ((currentRecipe.Active_Time_Units__c=='Minutes' && currentRecipe.Active_Time__c>=60) || currentRecipe.Active_Time_Units__c=='Hours' && currentRecipe.Active_Time__c>=1) {
            System.assert(currentRecipe.Complexity__c=='Difficult', 'Expected complexity to be Difficult');
            //If it's less than an hour but it has over 6 servings, the complexity should be moderate
            } 
            else if (currentRecipe.Servings__c>6) {
            System.assert(currentRecipe.Complexity__c=='Moderate', 'Expected complexity to be Moderate');
            //Otherwise, the complexity should be easy
            } 
            else {
            System.assert(currentRecipe.Complexity__c=='Simple', 'Expected complexity to be Simple');
            }
        
        }
    }
        
    @isTest static void checkRecipeComplexityOnUpdate(){
        //now update difficult recipes to moderate
        //create a list to update the recipes
        List<Recipe__c> recipesToChangeToModerate =  new List <Recipe__c> ();
        //SOQL for loop through difficult recipes from the system
        for (Recipe__c currentRecipe : [Select Active_Time_Units__c, Active_Time__c, Complexity__c, Servings__c
                                       FROM Recipe__c
                                       WHERE Active_Time_Units__c='Minutes' AND Active_Time__c>60]){
        //update the current recipe to values that should change the complexity to moderate
        currentRecipe.Active_Time__c = 45;
        currentRecipe.Servings__c = 7;
        recipesToChangeToModerate.add(currentRecipe);
        }
        //update the list
        update recipesToChangeToModerate;
        //now run a SOQL for loop for recipes where Active Time is 45 and Servings is 7 
        //and check that each one has a complexity of Moderate
        for(Recipe__c recipe:[SELECT Complexity__c 
                             FROM Recipe__c
                             WHERE Active_Time__c = 45
                              AND Servings__c = 7]){
        System.assert(recipe.Complexity__c=='Moderate', 'Expected complexity to be Moderate');
        
        }
        //update moderate recipes to easy
        //create a list to update the recipes
        List<Recipe__c> recipesToChangeToEasy =  new List <Recipe__c> ();
        //SOQL for loop through moderate recipes from the system
        for (Recipe__c currentRecipe : [Select Active_Time_Units__c, Active_Time__c, Complexity__c, Servings__c
                                       FROM Recipe__c
                                       WHERE Active_Time_Units__c='Minutes' AND Active_Time__c<60 AND Servings__c>6]){
        //update the current recipe to values that should change the complexity to easy
        currentRecipe.Active_Time__c = 42;
        currentRecipe.Servings__c = 2;
        recipesToChangeToEasy.add(currentRecipe);
        }
        //update the list
        update recipesToChangeToEasy;
        //now run a SOQL for loop for recipes where Active Time is 42 and Servings is 2 
        //and check that each one has a complexity of Simple
        for(Recipe__c recipe:[SELECT Complexity__c 
                             FROM Recipe__c
                             WHERE Active_Time__c = 42
                              AND Active_Time_Units__c = 'Minutes'
                              AND Servings__c = 2]){
        System.assert(recipe.Complexity__c=='Simple', 'Expected complexity to be Simple');
        
        }
        //update easy recipes to difficult
        //create a list to update the recipes
        List<Recipe__c> recipesToChangeToDifficult =  new List <Recipe__c> ();
        //SOQL for loop through simple recipes from the system
        for (Recipe__c currentRecipe : [Select Active_Time_Units__c, Active_Time__c, Complexity__c, Servings__c
                                       FROM Recipe__c
                                       WHERE Active_Time_Units__c='Minutes' AND Active_Time__c<60 AND Servings__c<6]){
        //update the current recipe to values that should change the complexity to difficult
        currentRecipe.Active_Time__c = 70;
        recipesToChangeToDifficult.add(currentRecipe);
        }
        //update the list
        update recipesToChangeToDifficult;
        //now run a SOQL for loop for recipes where Active Time is 70 
        //and check that each one has a complexity of Difficult
        for(Recipe__c recipe:[SELECT Active_Time__c, Servings__c, Complexity__c 
                             FROM Recipe__c
                             WHERE Active_Time__c = 70]){
        System.assert(recipe.Complexity__c=='Difficult', 'Expected complexity to be Difficult');
        
        }
    }
        @isTest static void checkRecipeUsagesWithNoRecipe(){
        //find a recipe record where it's not a draft
        Recipe__c recipe = [SELECT Id FROM Recipe__c WHERE Draft__c=FALSE LIMIT 1];
        //find a cookbook
        Cookbook__c cookbook = [SELECT Id FROM Cookbook__c LIMIT 1];
        //create and insert a recipe usage record using the above two records
        Recipe_Usage__c recipeUsage = new Recipe_Usage__c();
        recipeUsage.Cookbook__c = cookbook.Id;
        recipeUsage.Recipe__c = recipe.Id;
        insert recipeUsage;
        //start the test
        Test.startTest();
        //create a Boolean for if there was an exception
        Boolean thereWasAnException = FALSE;
        //open the try block
        try{
        //update the recipe usage recipe so that it has no recipe
        delete recipe;
        update recipeUsage; 
        }
        //
        //open the catch block to catch the exceptions
        catch(DMLException e) {
        thereWasAnException=TRUE;
        }
        Test.stopTest();
        System.assert(thereWasAnException, 'There should have been a DML exception');
    }
    @isTest static void checkCookbookTasks(){
        //Firstly use existing records to create some Recipe Usage records
        
        //create a list of cookbooks
        List <Cookbook__c> allcookbooks =  new List <Cookbook__c>([SELECT Id FROM Cookbook__c]);
        //create a counter to use as the index for different recipes
        Integer cookbookIndex=0;
        //create a list of Recipe Usage records to insert
        List <Recipe_Usage__c> recipeUsages = new List <Recipe_Usage__c>();
        //loop through all cookbooks and create a recipe usage record that links it and one of the recipes
        for (Recipe__c thisRecipe: [SELECT Id FROM Recipe__c]){
            Recipe_Usage__c newRecipeUsage= new Recipe_Usage__c();
            newRecipeUsage.Cookbook__c= allcookbooks.get(cookbookIndex).Id;
            newRecipeUsage.Recipe__c= thisRecipe.Id;
            recipeUsages.add(newRecipeUsage);
            if(cookbookIndex==9){
                cookbookIndex=1;   
                }
            else{
                cookbookIndex++;
                }
        }
        insert recipeUsages;
        
        //now I'll make a change to a few recipes so that the trigger fires
        //create a list to store the updates
        List <Recipe__c> recipesToUpdate= new List <Recipe__c> ();
        //create an integer for naming records
        Integer count=1;
        for (Recipe_Usage__c recipeUsage: [SELECT Recipe__r.Active_Time__c FROM Recipe_Usage__c WHERE Recipe__r.Draft__c=TRUE]){
            recipeUsage.Recipe__r.Description__c='What a lovely recipe';
            recipeUsage.Recipe__r.Active_Time__c=80;
            recipeUsage.Recipe__r.Active_Time_Units__c='Minutes';
            recipeUsage.Recipe__r.Name='Another recipe '+ count;
            recipeUsage.Recipe__r.Servings__c=3;
            count++;
            recipesToUpdate.add(recipeUsage.Recipe__r);
            
        }
        update recipesToUpdate;
        
        //create a map to store Ids and cookbook records
        Map <Id, Cookbook__c> cookbookMap = new Map <Id, Cookbook__c>();
        //loop throuh all recipe usage records
        for (Recipe_Usage__c recipeUsage: [SELECT Recipe__r.Draft__c, Recipe__c, Cookbook__c, Cookbook__r.Id FROM Recipe_Usage__c WHERE Recipe__r.Id IN:recipesToUpdate]){
            //if the current recipe usage's recipe is not a draft
            if(recipeUsage.Recipe__r.Draft__c==FALSE){
            //then assert that the current recipe usage's cookbook only has one task
                system.assert(recipeUsage.Cookbook__r.Tasks.size()==1, 'Expected cookbook to have exactly 1 task when it has '+recipeUsage.Cookbook__r.Tasks.size());
            //then add the related cookbook to the map
            cookbookMap.put(recipeUsage.Cookbook__r.Id, recipeUsage.Cookbook__r);
            }
            
        }
        
        //find all tasks associated with the cookbooks in the map
        for (Cookbook__c currentCookbook : [SELECT Id, OwnerId, (SELECT OwnerId, WhatId, Subject, ActivityDate FROM Tasks) FROM Cookbook__c WHERE Id IN: cookbookMap.values()]){
            //assert that the cookbook only has one task
            system.assert(currentCookbook.Tasks.size()==1, 'Expected cookbook to have exactly 1 task when it has '+currentCookbook.Tasks.size());
            //loop through the cookbook's tasks 
            for(Task task: currentCookbook.Tasks){
                //assert that the task's ActivityDate is today+7
                system.assert(task.ActivityDate==system.today()+7, 'Expected the activity date to be today +7');
            }
        }
        
    }
        
        
       
        
        
}