@isTest
private class ProjectTriggerHandlerTest
{
    static testmethod void createGrantsTest()
    {
        Profile p1 = [select id from profile where name='System Administrator'];  
        User u1 = new User(alias = 'TimeUsr3', email='TimeTestUser3@testorg.com', 
            emailencodingkey='UTF-8', lastname='TimeTestUser3', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p1.Id, 
            timezonesidkey='America/Los_Angeles', username='TimeTestUser3@testorg.com');
            
        System.runAs(u1)
        {
            List<VSO_Project__c> lsttoinsert=new List<VSO_Project__c>();
            for(Integer i=0;i<5;i++)
            {
                VSO_Project__c project=new VSO_Project__c(Name='Test Project'+i,Goals__c='Education',Core_Programme_Area__c='E01 Education');
                lsttoinsert.add(project);
            }
            insert lsttoinsert;
        }
    }
}