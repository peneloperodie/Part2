public with sharing class WeekTwoHomework {
    public static void accountListQuery() {
        //A method that includes a query for a List of contacts and returns the Account Name 
        //and Industry as well.  Use a loop to print the name of each Contact’s Account Name 
        //with System.debug.
        List <Contact> contactsList = [SELECT FirstName, LastName, Account.Name, Account.Industry
        FROM Contact LIMIT 50];
        for (Contact currentContact: contactsList){
            System.debug('Current contact\'s account name is: ' +currentContact.Account.Name);
        }
    }
    public static void accsWithClosedOneOppsQuery(){
        //A method that includes a query for a list of Accounts AND includes all their 
        //closed-won opportunities in a subquery. Use a loop to print out the name of each Account’s 
        //opportunity with System.debug.
        List <Account> accsWithOppsList = [SELECT Name, (SELECT Name FROM Opportunities WHERE StageName = 'Closed Won')
        FROM Account WHERE AnnualRevenue>1000000];
        for (Account accountRecord: accsWithOppsList){
            System.debug('Current account\'s opportunities are '+ accountRecord.Opportunities);
        }
    }
    public static Map<Id, Opportunity> getOpportunitiesMap(){
        //A method that queries for Opportunity records that returns results in a map format.
        Map <Id, Opportunity> opportunityMap = new Map <Id, Opportunity> ([SELECT Name, StageName FROM Opportunity WHERE StageName='Closed Won']);
        return opportunityMap;
        
    }
    public static Integer getNumberOfOpenOpps(){
        Integer numberOfOpenOpps = [SELECT COUNT() FROM Opportunity WHERE IsClosed=FALSE];
        System.debug('There are ' + numberofOpenOpps + ' open opportunities in this org');
        return numberOfOpenOpps;
    }
}
