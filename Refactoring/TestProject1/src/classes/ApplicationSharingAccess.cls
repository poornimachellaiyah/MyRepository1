/* 
* Developer :Narpavi-TPT
* Date:20-July-2015 
* Change Search :SS-2373660
* Comments:The 'Batch Apex Class' is execute by using the 'Apex Sharing Recalculation' in Application object to set the access for the existing application records
*/

Global class ApplicationSharingAccess implements Database.Batchable<sObject>{


Global Database.QueryLocator start(Database.BatchableContext BC)
{ 
    string query;
    
    //logic for the test class code coverage
    //If part will be execute only when the batch class is executed.        
    if(!Test.isRunningTest()){
         query='SELECT Id,Job__r.Type__c,Job__r.Country__r.Name,Job__r.id,Job__r.Country__r.Country_People_Manager__c,Job__r.Country__r.Country_People_Manager__r.UserRole.Id,Job__r.Country__r.Country_Director__c,Job__r.Country__r.Country_Director__r.UserRole.Id,Job__r.Hiring_Manager__c,Relationship_Manager__c FROM Application__c where CreatedDate > 2015-07-03T00:00:00Z and CreatedDate < 2015-07-16T00:00:00Z' ;      
    }
    
    //Else part will be execute only when the test class executes.
    else{ 
         query='SELECT Id,Job__r.Type__c,Job__r.Country__r.Name,Job__r.id,Job__r.Country__r.Country_People_Manager__c,Job__r.Country__r.Country_People_Manager__r.UserRole.Id,Job__r.Country__r.Country_Director__c,Job__r.Country__r.Country_Director__r.UserRole.Id,Job__r.Hiring_Manager__c,Relationship_Manager__c FROM Application__c' ;      
    }
    return Database.getQueryLocator(query);
}

Global void execute(Database.BatchableContext BC,List<Application__c> appRecords)
{  
     updateApplication(appRecords);
}
  
 //Method to set sharing access for the profiles Country People Manager,Country People Director,Hiring Manager, Relationship Manager and Employee Panel selection Member
private void updateApplication(List<Application__c> appRecords)
{  

    //Create user map to find user IDs
        Map<Id, User> userIdMap = new Map<Id, User>();
        for(User u : [SELECT Id FROM User WHERE IsActive=true]){
            userIdMap.put(u.Id, u);
        }
   
    List<Application__Share> applicationShares = new List<Application__Share>();
    List<Job__Share> jobShares = new List<Job__Share>();
  
     for(Application__c a : appRecords)
    { 
         //get the Employee selection Panel Member linked to the job record 
         List<Employee_Selection_Panel__c>  panel = [ SELECT Id, Employee_Selection_Panel_Member__c, Related_Job__c,Related_Job__r.id FROM Employee_Selection_Panel__c where Related_Job__r.id=:a.Job__r.id];        
           
            //logic to set read access for the application record to the Country Director 
            if (a.Job__r.Country__r.Country_Director__r.UserRole.Id != null && userIdMap.get(a.Job__r.Country__r.Country_Director__c) != null)
            {
                Application__Share astmp1 = (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.Id, a.Job__r.Country__r.Country_Director__c, 'Application__Share', 'read', 'Country_Director__c');
                applicationShares.add(astmp1);
            }
            
            //logic to set edit access for the application record to the Country People Manager 
            if (a.Job__r.Country__r.Country_People_Manager__r.UserRole.Id !=null && userIdMap.get(a.Job__r.Country__r.Country_People_Manager__c) != null) 
            {  
               Application__Share astmp2 = (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.Id, a.Job__r.Country__r.Country_People_Manager__c, 'Application__Share', 'edit', 'Country_People_Manager__c');
               applicationShares.add(astmp2);          
            }
      
            //logic to set edit access for the application record to the Hiring Manager 
            if (a.Job__r.Hiring_Manager__c != null && userIdMap.get(a.Job__r.Hiring_Manager__c)!= null) 
            {
                   Application__Share astmp3 = (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.Id, a.Job__r.Hiring_Manager__c, 'Application__Share', 'edit', 'Hiring_Manager__c');
                   applicationShares.add(astmp3);
            }
      
            //logic to set edit access for the application record to the Relationship Manager
            if (a.Relationship_Manager__c !=null && userIdMap.get(a.Relationship_Manager__c)!= null)          
            {
                   Application__Share astmp4 = (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.Id, a.Relationship_Manager__c, 'Application__Share', 'edit', 'Relationship_Manager__c');
                   applicationShares.add(astmp4);            
            }
      
            //logic to set edit access for the application record to the Employee Selection Panel Member
            if (panel.size()>0 && panel[0].Employee_Selection_Panel_Member__c!= null && userIdMap.get( panel[0].Employee_Selection_Panel_Member__c)!= null)
            {
                  Application__Share astmp5 = (Application__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.id,panel[0].Employee_Selection_Panel_Member__c, 'Application__Share', 'edit', 'Employee_Selection_Panel_Member__c');
                  applicationShares.add(astmp5);
            } 
                                                   
           //logic to set edit access for the job record to the Relationship Manager    
            if (a.Relationship_Manager__c !=null && userIdMap.get(a.Relationship_Manager__c)!= null)   
            {
                Job__Share job1 = (Job__Share)RecordSharingUtilityClass.CreateShareRecordSingle(a.Job__r.Id,a.Relationship_Manager__c, 'Job__Share', 'edit', 'Relationship_Manager__c');
                jobshares.add(job1);
            }  
     }    
     try
     { 
          if(jobshares.Size()>0)
           insert jobshares;
          if(applicationShares.Size()>0)
            insert applicationShares; 
      }
      catch(Exception ex) 
       {
          System.debug('Exception in ApplicationSharingAccess'+ex.getMessage());                                 
       }              

}

 Global void finish(Database.BatchableContext BC){} 
}