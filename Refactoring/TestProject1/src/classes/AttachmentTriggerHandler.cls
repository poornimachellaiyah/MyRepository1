/*Dinesh-TPT-RecruitV2 changes-06/June/2015
 class created to get the information about the attached file in 'Notes and Attachments' section.*/
 
public without sharing class AttachmentTriggerHandler { 

    private AttachmentTriggerHandler()
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
                 updateFieldinJob();                      
         }     
    }
    
    /*Dinesh-TPT-RecruitV2 changes-06/June/2015.
    Method to find whether the attached document name contains "VSOJD" and update the help field in 'Job' custom object. */  
    private void updateFieldinJob()
    {
        String Title;
        Id pId;
        List<Attachment> listAttachment=[SELECT id,ParentId,Name FROM Attachment where id IN:trigger.new];
        try
        {
            if(listAttachment.Size()>0)
            {
                Title=listAttachment[0].Name;
                if((Title!=null) && (Title!=''))  
                {
                    Job__c job=new Job__c();
                    job.id=listAttachment[0].ParentId;
                    if(Title.contains('VSOJD'))
                        job.help_JD_Attached__c =true;
                    else
                        job.help_JD_Attached__c =false;
                    update job;        
                }  
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception in AttachmentTriggerHandler'+ex.getMessage());
        }
    }
    
    
    public static AttachmentTriggerHandler getHandler(){
            if(handler == null){
                handler = new AttachmentTriggerHandler();
            }
            return handler;
     }
    
    private static AttachmentTriggerHandler handler;
}