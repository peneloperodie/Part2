@isTest
public class DataFactory {
    //Method 2: Creates, inserts, and returns Ingredient SObjects
    //It should take a parameter that dictates the number of Ingredients to be created and returned
    public static List<Ingredient__c> insertAndReturnIngredients(Integer numberOfIngredients){
        //create a recipe and insert it
        Recipe__c recipe = new Recipe__c();
        recipe.Name = 'Great recipe';
        recipe.Active_Time__c = 30;
        recipe.Active_Time_Units__c = 'Minutes';
        recipe.Servings__c = 4;
        recipe.Description__c = 'This is fabulous and simple recipe';
        insert recipe;
        System.debug('The newly created recipe has an id of '+recipe.Id);
        
        //create a list to hold the new ingredients SObjects
        List<Ingredient__c> newIngredients = new List <Ingredient__c>();
      
        //user the numberofIngredients integer in a for loop to create the desired number of Ingredients
        for (Integer counter=1; counter <= numberofIngredients; counter ++){
            Ingredient__c ingredientRecord = new Ingredient__c();
            ingredientRecord.Name = 'Ingredient '+counter;
            ingredientRecord.Recipe__c=recipe.Id;
            //add each one to the list
            newIngredients.add(ingredientRecord);
        }
        
        //It SHOULD INSERT the records and return them
        insert newIngredients;
        System.debug('This is the newIngredients list: '+newIngredients);
        return newIngredients;
        
    }


}
