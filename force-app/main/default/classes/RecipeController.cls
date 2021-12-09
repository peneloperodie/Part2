public inherited sharing class RecipeController {
    @AuraEnabled(Cacheable=true)
    public static Recipe__c[] getAllRecipes() {
        return [
            SELECT
                Id,
                Name,
                Draft__c,
                Active_Time__c,
                Active_Time_Units__c,
                Complexity__c,
                Needs_Review__c,
                Possible_Duplicate__c,
                Season__c
            FROM Recipe__c
            ORDER BY Name
            LIMIT 50
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static Recipe__c[] searchRecipes(String searchTerm) {
        // Return all recipes when no search term
        searchTerm = searchTerm.trim();
        if (searchTerm == '') {
            System.debug('returning: '+getAllRecipes());
            return getAllRecipes();
        }
        // Prepare query paramters
        searchTerm = '%' + searchTerm + '%';
        // Execute search query
        return [
            SELECT
                Id,
                Name,
                Draft__c,
                Active_Time__c,
                Active_Time_Units__c,
                Complexity__c,
                Needs_Review__c,
                Possible_Duplicate__c,
                Season__c
            FROM Recipe__c
            WHERE Name LIKE :searchTerm
            ORDER BY Name
            LIMIT 50
        ];
    }
     @AuraEnabled(Cacheable=true)
     /*This method takes a few parameters (a.k.a. inputs, a.k.a. arguments)  
    The first three all that define the Ingredient: Name, Measurement amount, Measurement type
    The last parameter is the SObject ID for the recipe this ingredient should be attached to
    **You may need to activate the picklist options for Ingredient Measurement Type:
    */
    public static void addIngredient(String ingredientName, Integer measurementAmount, String measurementType, ID recipeId){
        	Ingredient__c ingredient        = new Ingredient__c();
            ingredient.name                 = ingredientName;
        	ingredient.Measurement__c		= measurementAmount;
            ingredient.Measurement_Type__c  = measurementType;
            ingredient.Recipe__c            = recipeId;
         
    //Insert the ingredient
		    insert ingredient;

    }
    
    @AuraEnabled(Cacheable=true)
    public static List < Ingredient__c > generateGroceryList(ID recipeId){
        /*This method gets the list of ingredients that are children of a Recipe. 
         It gets the recipe id as a parameter, queries for and returns the Ingredient records, 
         including the following fields: ID, Name, Measurement__c, Measurement_Type__c, Notes__c
		*/
        List<Ingredient__c> ingredientList = [SELECT Id, Name, Recipe__c, Measurement__c, Measurement_Type__c, Notes__c FROM Ingredient__c
                                             WHERE Recipe__c =:recipeId];
                                        
        Return ingredientList;
        
    }
 	@AuraEnabled(Cacheable=true)
    public static List < Ingredient__c > scaleRecipeForServings (ID recipeId, Decimal desiredServings) {
	/*This one may be challenging!  
	Each Recipe has a field that indicates how many servings it makes.  
	This method will need to loop through the ingredients, and scale the ingredient amount up or down, 
	based on how many servings it should be now.  It should use the same measurement type, 
	no need to convert tablespoons to cups, etc.
	For example, let’s say my recipe serves 4 and currently calls for 4 cups of flour.  
	If this method was called, with the number 2, my ingredient should be updated to call for 2 cups of flour. 
	We halved the recipe!  If the method was called with the number 8, to now serve 8, 
	it should end up with 4 cups of flour.Update the Measurement__c field on each ingredient 
	in the recipe and return the list of updated ingredients.  
	You don’t have to commit these to the database with DML, just return them for a preview. 
	(If you do commit the changes, that’s fine too!)
	*/	
        list<Ingredient__c> ingredientMeasurement = new List <Ingredient__c>();
        list<Ingredient__c> ingredientList = [ Select Id, Name, Notes__c, Recipe__c,Measurement_Type__c, Recipe__r.Servings__c, Measurement__c FROM Ingredient__c
                                      WHERE Recipe__c=:recipeId];
        for(Ingredient__c ingredient:ingredientList){
            
        ingredient.Measurement__c   = ingredient.Measurement__c * (desiredServings/ingredient.Recipe__r.Servings__c);
        ingredientMeasurement.add(ingredient);
        
            
 			}
        return ingredientMeasurement;
    }
}