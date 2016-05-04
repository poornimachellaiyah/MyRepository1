@isTest
private class TimesheetSendEmailAlertsTest
{
         
            
    private static testmethod void testSendEmail1()
    {
        Profile p1 = [select id from profile where name='System Administrator']; 
        User usr1 = new User(alias = 'tstusr', email='timesheet_testuser1@testorg.com', 
        emailencodingkey='UTF-8', lastname='timesheet_testuser1', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p1.Id, 
        timezonesidkey='America/Los_Angeles', username='timesheet_testuser1@testorg.com');    
        System.runAs(usr1)
        {        
           fHCM2__Department__c dept=new fHCM2__Department__c(Name='Test HR Department');
            insert dept;
            
            //Create Team Member records
            
            fHCM2__Team_Member__c Manager1 = new fHCM2__Team_Member__c(fHCM2__First_Name__c = 'Test', fHCM2__Surname__c = 'Manager1', fHCM2__Department__c = dept.id);
            fHCM2__Team_Member__c Manager2 = new fHCM2__Team_Member__c(fHCM2__First_Name__c = 'Test', fHCM2__Surname__c = 'Manager2', fHCM2__Department__c = dept.id);
            insert Manager1;
            insert Manager2;
                
            List<fHCM2__Team_Member__c> tmlist=new List<fHCM2__Team_Member__c >();
            for(Integer i=1;i<=5;i++)
            {
                fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(fHCM2__First_Name__c = 'Test'+i, fHCM2__Surname__c = 'timesheetTest', 
                                        fHCM2__Job_Title__c = 'title', fHCM2__Manager__c = Manager1.Id, fHCM2__Department__c = dept.id,fHCM2__User__c=usr1.id);
                tmlist.add(tm);
            }
            for(Integer i=1;i<=5;i++)
            {
                fHCM2__Team_Member__c tm = new fHCM2__Team_Member__c(fHCM2__First_Name__c = 'Test'+i, fHCM2__Surname__c = 'timesheetTest', 
                                        fHCM2__Job_Title__c = 'title', fHCM2__Manager__c = Manager2.Id, fHCM2__Department__c = dept.id,fHCM2__User__c=usr1.id);
                tmlist.add(tm);
            }
            insert tmlist;
            
                     
            
            string query ='SELECT id,Name,fHCM2__Department__r.Name FROM fHCM2__Team_Member__c limit 5';   
            Test.startTest();
            TimesheetSendEmailAlerts TestEmailAlert1 = new TimesheetSendEmailAlerts(query,25);
            Database.executeBatch(TestEmailAlert1,5); 
            
            TimesheetSendEmailAlerts TestEmailAlert2 = new TimesheetSendEmailAlerts(query,1);
            Database.executeBatch(TestEmailAlert2,5);
            
            TimesheetSendEmailAlerts TestEmailAlert3 = new TimesheetSendEmailAlerts(query,3);
            Database.executeBatch(TestEmailAlert3,5);  
            Test.stopTest();
        }
    }
    
}