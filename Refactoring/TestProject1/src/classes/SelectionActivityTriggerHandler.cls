/*
******************************************************************   
 Change log:Code Streamlining. Search Tag : TPT-(27-Nov-2015)
                        
****************************************************************** 
*/ 

public without sharing class SelectionActivityTriggerHandler
{
    private SelectionActivityTriggerHandler()
    {
        if(!trigger.isExecuting)
        {
            throw new InternalException('Not in Trigger context!');
        }
    }
    
    public void execute()
    {
        if(trigger.isAfter)
        {
            if(trigger.isUpdate || trigger.isInsert)
            {
                this.UpdateContactDetails();
                this.updateRecruitmentPartner();
            }
        }
    }
    
    //Dinesh-TPT-Knowledge Exchange Changes-10/June/2015
    //Method to set the RecruitmentPartner field in 'Application' and 'Contact' objects.
    //Narpavi-TPT-(27-Nov-2015)-(SS-4694129)-Code Streamlining
    private void updateRecruitmentPartner()
    {
        List<Account> listAccount=[SELECT Id, Name FROM Account WHERE Name='Recruitment Partner - VSO Netherlands'];
        if(listAccount.size()>0)
        {
            try
            {   
                List<Application_Selection_Tool__c> newselection=[select id, Application__r.Knowledge_Exchange_Applicant__c,Application__r.id,Application__r.applicant__c from Application_Selection_Tool__c where Id IN:trigger.new];
                                
                List<Application__c >appToUpdate=new List<Application__c >();
                List<Contact> conToUpdate= new list<Contact>();
                
                for(Application_Selection_Tool__c selection: newselection)
                {
                    //Condition to check whether the applicant is KE applicant or not
                    if(selection.Application__r.Knowledge_Exchange_Applicant__c)
                    {                        
                        Application__c app=new Application__c();                                               
                        Contact contact=new Contact();
                     
                        app.id=selection.Application__r.id;
                        app.Assigned_Recruitment_Partner__c=listAccount[0].id;
                        appToUpdate.add(app);
                
                        contact.id=selection.Application__r.applicant__c;
                        contact.Recruitment_Partner__c=listAccount[0].id;
                        conToUpdate.add(contact);
                    }
                }                
                if(appToUpdate.size()>0)
                    update appToUpdate;                
                if(conToUpdate.size()>0)
                    update conToUpdate;
             }
             catch(Exception ex)
             {
                 System.debug('Exception in SelectionActivityTriggerHandler '+ex.getMessage());
             }
        }    
    
    }
    
   //Narpavi-TPT-(27-Nov-2015)-(SS-4694129)-Code Streamlining
   //Streamline the select statement
   public void UpdateContactDetails()
   {     
       List<Application_Selection_Tool__c> newselection=trigger.new;      //TPT-(27-Nov-2015)
       
       List<Contact> contactToUpdate = new List<Contact >();  
                     
       for(Application_Selection_Tool__c selection:newselection)
       {          
          //string contactid=selection.Contact__c;   
          //List<contact> contact=[select id,Date_Last_Passed_Selection__c from contact where id=:contactid];          
          if(selection.Contact__c<>null)
          {              
               Contact contact=new Contact();
               contact.id=selection.Contact__c;               
                              
               if(selection.Help_Type__c=='Blended Selection'||selection.Help_Type__c=='Assessment Day' )
               {                     
                   if(selection.Overall_Selection_Outcome__c=='Failed Selection')
                   {                          
                       contact.Date_Last_Failed_Selection__c= selection.Outcome_Decision_Date__c;
                       contact.Period_Until_Suitable_for_Reassessment__c='12 Months';                          
                   }
                   if(selection.Overall_Selection_Outcome__c=='Passed Selection')
                   {
                        contact.Date_Last_Passed_Selection__c = selection.Outcome_Decision_Date__c;                           
                   }                   
               }           
               else if(selection.Help_Type__c =='Preliminary Interview')
               {                         
                   if(selection.Interview_Result__c=='Failed')
                  {
                       contact.Date_Last_Failed_Selection__c= selection.Interview_Date__c;
                       contact.Period_Until_Suitable_for_Reassessment__c='6 Months';
                  }                                 
               }
            contactToUpdate.add(contact);               
               
          }
       }        
       if(contactToUpdate.size()>0)    
              update contactToUpdate;                       
   }
     
    public static SelectionActivityTriggerHandler getHandler()
    {
        if(handler == null){
            handler = new SelectionActivityTriggerHandler();
        }
        return handler;
    }
    
    private static SelectionActivityTriggerHandler handler;

}