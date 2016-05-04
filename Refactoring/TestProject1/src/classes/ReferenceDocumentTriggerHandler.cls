/*
* Description:Created to set the sharing access for the Hiring Manager to the Reference Document object
* Developer Name : Narpavi
* Company        : TPT
* Date created   : 16-09-2015
* Jira Issue  /Project   :References (SCS-2211)                    
*/

public without sharing class ReferenceDocumentTriggerHandler 
{


    private ReferenceDocumentTriggerHandler (){        
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }

    public void execute(){    
        if(Trigger.isAfter){
            if(Trigger.isInsert)
            {             
              referenceHiringManagerShareOnInsert();                          
            }              
        }
       
    }
         

 //Method created to set edit access for the Hiring Manager 
 public void referenceHiringManagerShareOnInsert()
   {
      List<Reference_Document__Share> referShareList=new List<Reference_Document__Share>();
      Reference_Document__Share rShare;    
      
      List<Reference_Document__c> Scope=Trigger.new; 
      Map<Id,Reference_Document__c> Mapreference=new Map<Id,Reference_Document__c>([SELECT id,On_Boarding_Check__r.RecordType.DeveloperName,Application__r.Job_Type__c,Application__r.Job__r.Hiring_Manager__r.id,Application__r.Job__r.Volunteer_Type__c FROM Reference_Document__c WHERE id IN:Scope]);
      for(Reference_Document__c reference: Mapreference.values())
      {
         rShare= new Reference_Document__Share();
         if(reference.Application__r.Job__r.Hiring_Manager__r.id!=null)
         {
          
           
           User u = [SELECT id,isActive FROM user WHERE id=:reference.Application__r.Job__r.Hiring_Manager__r.id];           
           
           if(u.IsActive)
           {
               if(reference.On_Boarding_Check__r.RecordType.DeveloperName=='Employee_Consultant'&& (reference.Application__r.Job_Type__c=='Employee Job' || reference.Application__r.Job_Type__c=='Consultant Job'))
               {
                   rShare.ParentId=reference.id;
                   rShare.UserOrGroupId=reference.Application__r.Job__r.Hiring_Manager__r.id;
                   rShare.AccessLevel='Edit';
                   rShare.RowCause=Schema.Reference_Document__Share.RowCause.Hiring_Manager_Access_To_Reference_Doc__c;
                   referShareList.add(rShare);
               }
               
               else if(reference.On_Boarding_Check__r.RecordType.DeveloperName=='Volunteer'&& reference.Application__r.Job_Type__c=='Volunteer Job' && reference.Application__r.Job__r.Volunteer_Type__c=='Volunteering Within VSO') 
               {
                   rShare.ParentId=reference.id;
                   rShare.UserOrGroupId=reference.Application__r.Job__r.Hiring_Manager__r.id;
                   rShare.AccessLevel='Edit';
                   rShare.RowCause=Schema.Reference_Document__Share.RowCause.Hiring_Manager_Access_To_Reference_Doc__c;
                   referShareList.add(rShare);
               }
           }      
         }      
      }   
      if(referShareList.Size()>0)
      {
         Database.SaveResult[] lsr = Database.insert(referShareList,false);
         Integer i=0;
         for(Database.SaveResult sr : lsr)
         {
            if(!sr.isSuccess())
            {
               Database.Error err = sr.getErrors()[0];
               if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION 
                   && err.getMessage().contains('AccessLevel')))
                   {                       
                      trigger.newMap.get(referShareList[i].ParentId). addError( 'Unable to grant sharing access due to following exception: ' + err.getMessage());
                   }
            }
            i++;
         }        
      }      
   }  
 
 public static ReferenceDocumentTriggerHandler getHandler(){
        if(handler == null){
            handler = new ReferenceDocumentTriggerHandler ();
        }
    return handler;
    }
    
    private static ReferenceDocumentTriggerHandler handler;
 
}