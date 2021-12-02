public with sharing class RecipeTriggerHandler {

    /*Create a method that will be called before a recipe is inserted or updated to check if it 
    is missing key values.  If it is missing one or more of the following, 
    check the Draft__c field on the recipe:
    Name
    Active_Time__c
    Description__c
    Active_Time_Units__c
    Servings__c*/
    public static void checkKeyValues(List<Recipe__c> recipeList){
        //loop through the list of recipes
        for(Recipe__c currentRecipe : recipeList){
            
            //print current values to debug log
            system.debug('Current recipe name is'+ currentRecipe.Name + ', Active Time is '+ currentRecipe.Active_Time__c
            +', Description is ' +currentRecipe.Description__c+', Active Time Units is '+currentRecipe.Active_Time_Units__c
            +' and Servings is '+currentRecipe.Servings__c);
            
            //if any of the values is blank...
            if(currentRecipe.Name == NULL ||
            currentRecipe.Active_Time__c == NULL ||
            currentRecipe.Description__c == NULL ||
            currentRecipe.Active_Time_Units__c == NULL ||
            currentRecipe.Servings__c == NULL){
                //then throw an error
                currentRecipe.addError('This recipe needs to have values in name, active time, description, active time units and servings');
                //then check the Draft__c checkbox
                //currentRecipe.Draft__c = TRUE;
                //print value of Draft to debug log
                //system.debug('the value of Draft is '+currentRecipe.Draft__c);
            }
            }
        }

    /*We also want to rate the complexity of a recipe. 
    Create a method that checks before a recipe is inserted or updated and does the following:*/
    public static void updateRecipeComplexity(List<Recipe__c> recipeList){
        /*Calls out to a method on the HelperFunctions class called rateRecipeComplexity.
        Gets the numerical rating back from the method and use it to fill in the Complexity__c field.*/

        //loop through each recipe in the trigger
        for(Recipe__c currentRecipe: recipeList){
            //print current complexity value to debug log
            system.debug('The old value of this recipe\'s complexity is '+currentRecipe.Complexity__c);
            if(HelperFunctions.rateRecipeComplexity(currentRecipe)==3){
                currentRecipe.Complexity__c='Difficult';
            }
            else if(HelperFunctions.rateRecipeComplexity(currentRecipe)==2){
                currentRecipe.Complexity__c='Moderate';
            }
            else if(HelperFunctions.rateRecipeComplexity(currentRecipe)==1){
                currentRecipe.Complexity__c='Simple';
            }
            
            //print value to the debug log
            system.debug('The new value of this recipe\'s complexity is '+currentRecipe.Complexity__c);
        }
    }

    /*After a recipe is updated, if it’s not a draft recipe, and if it’s being used in any cookbooks, 
    we want to create a review task.*/
    public static void createReviewTask(List<Recipe__c> recipeList){
        /*Check for a Recipe Usage record, indicating this recipe is used in a cookbook
        Use SOQL to find all Recipes that have a recipe usage record*/
        List<Recipe_Usage__c> recipeUsageList = new List<Recipe_Usage__c>([
            SELECT Name, Recipe__c, Recipe_Usage__c.Recipe__r.Draft__c, Recipe_Usage__c.Recipe__r.Name, Cookbook__c, Recipe_Usage__c.Cookbook__r.OwnerId, Recipe_Usage__c.Cookbook__r.Name
            FROM Recipe_Usage__c  
            WHERE Recipe__c IN:recipeList]);
        system.debug('Here are the recipe usage records '+ recipeUsageList);

            //create a Map to hold 1 task per cookbook to be created
            Map<Id, Task> newTasksMap = new Map<Id, Task>();
            //create a list to add the new tasks in via DML
            List<Task> newTasksList = new List<Task>();
            
            //loop through the list of recipe with usage records
        for(Recipe_Usage__c currentRecipeUsage:recipeUsageList){
            if(currentRecipeUsage.Recipe__r.Draft__c==FALSE){
                //then create a Task record
                system.debug('The recipe ' + currentRecipeUsage.Recipe__r.Name +'is getting a task for the cookbook '+ currentRecipeUsage.Cookbook__r.Name);
                Task newTask = new Task();
                newTask.OwnerId = currentRecipeUsage.Cookbook__r.OwnerId;
                newTask.WhatId = currentRecipeUsage.Cookbook__c;
                newTask.Subject = 'Review Updates to Recipe: '+currentRecipeUsage.Recipe__r.Name;
                newTask.ActivityDate = system.today()+7;
                newTasksMap.put(currentRecipeUsage.Cookbook__c, newTask);


            }
        }
        //add all the map values (i.e Task records) to the newTasksList
        newTasksList.addAll(newTasksMap.values());
        //use DML to insert the newTasksList
        insert newTasksList;
    }



}