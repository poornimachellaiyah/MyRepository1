/* 
*Developer :Narpavi-TPT
*Date:22-Jan-2016 
*Change Search :SS-7665778
*Comments:The 'Batch Apex Class'is execute to set the access for the existing application records only for the Corporate Recruitment Group Users 
*/


Global class CorporateGroupSharingAccess implements Database.Batchable<sObject>{


Global Database.QueryLocator start(Database.BatchableContext BC)
{ 
     string query;           
     query='SELECT Id,Job__r.Type__c,Applicant_is_Corporate__c,Knowledge_Exchange_Applicant__c FROM Application__c where Applicant_is_Corporate__c= TRUE OR Knowledge_Exchange_Applicant__c =TRUE';         
     return Database.getQueryLocator(query);
}

//Method to get the users from Corporate Recruitment Group 
private string getcorporateId()
{                   
     string corporateId;
     
     Map<Id, GroupMember> groupmemId = new Map<Id, GroupMember>([select id, GroupId, UserOrGroupId,Group.Name from GroupMember where Group.Name='Corporate Recruitment']);     
     for(GroupMember gmemId :groupmemId .values() )
      {         
         corporateId=gmemId.GroupId;                   
      }   
            
      return corporateId; 
}
         
Global void execute(Database.BatchableContext BC,List<Application__c> appRecords)
{  
     string corpId=getcorporateId();
     if(corpId!=null){
     updateApplication(appRecords,corpId);
     }
}
        
//Method to set sharing access for the Corporate Recruitment Group Users
private void updateApplication(List<Application__c> appRecords, string corpId)
{
    List<Application__Share> applicationShares = new List<Application__Share>();
    Application__Share rShare;
      
    for(Application__c a : appRecords)
    {                    
             rShare=new Application__Share();  
            if ((a.Applicant_is_Corporate__c==True) || (a.Knowledge_Exchange_Applicant__c == True))
            {            
                  rShare.ParentId=a.id;                  
                  rShare.UserOrGroupId=corpId;
                  rShare.AccessLevel='Edit';                 
                  applicationShares .add(rShare);
            }                                                                      
      }    
     try
     {           
          if(applicationShares.Size()>0)
            insert applicationShares; 
      }
      catch(Exception ex) 
       {
            string errorMsg=Ex.getmessage();
            string errorClass='CorporateGroupSharingAccess';
            string errorStack=Ex.getStackTraceString();
            string errorType=Ex.getTypeName();
            //log the exception
            ApplicationErrorLogController obj=new ApplicationErrorLogController();
            obj.logError(errorClass,errorMsg,errorStack,errorType);                                             
       }              

}

 Global void finish(Database.BatchableContext BC){} 
}