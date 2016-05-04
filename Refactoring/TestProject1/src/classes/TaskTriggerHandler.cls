/*Dinesh-TPT-Recruit Phase-2 changes-06/July/2015
 class created to get the information about the Task in Activity History section.*/
 
public without sharing class TaskTriggerHandler { 

    private TaskTriggerHandler()
    {
        if(!trigger.isExecuting)
        { 
            throw new InternalException('Not in Trigger context!'); 
        }
    }
    
    public void execute() 
    {
         if(Trigger.isAfter)
         {
            if (Trigger.isInsert)             
                updateOfferFields();                 
         }     
    }
    
    //Dinesh-TPT-Recruit Phase-2 changes-06/July/2015.
    //Method to update 'Conditional Offer Date' field in offer object
    public void updateOfferFields()
    {
         List<Task> task=[SELECT id, WhatId, Subject, ActivityDate FROM task WHERE id IN:trigger.new AND Subject=:'Email: VSO Conditional Offer'];
         
         if(task.size()>0)
         {
             List<Offer__c> listOffer=[SELECT id,RecordType.DeveloperName FROM Offer__c WHERE id=:task[0].WhatId];
         try
         {   
             //TPT-Poornima - Added employee offer in the condition for Emp O&O changes - dated 17/11/2015
             if((listOffer.size()>0)&&(listOffer[0].RecordType.DeveloperName=='Volunteer_Offer' || listOffer[0].RecordType.DeveloperName=='Employee_Offer' ))
             {   
                 Offer__c offer=new Offer__c();
                 offer.id=task[0].WhatId;
                 offer.Conditional_Offer_Date__c=task[0].ActivityDate;
                 update offer;                          
             }
         }
         catch(Exception ex)
         {
            System.debug('Exception in TaskTriggerHandler'+ex.getMessage());
         }
        }
    }
    
    
    public static TaskTriggerHandler getHandler(){
            if(handler == null){
                handler = new TaskTriggerHandler();
            }
            return handler;
     }
    
    private static TaskTriggerHandler handler;
}