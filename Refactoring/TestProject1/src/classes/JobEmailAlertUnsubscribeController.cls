Public class JobEmailAlertUnsubscribeController{

public Contact contact {get;set;}
public String errormsg{get;set;}
public boolean validationCheck{get;set;}
public String contactId;

public JobEmailAlertUnsubscribeController(Apexpages.standardcontroller controller)
{
 this();
}

public JobEmailAlertUnsubscribeController()
{
contactId=ApexPages.currentPage().getParameters().get('UnsubscribeId');
}

public void doUpdateContactField()
{
   errormsg='';
   validationCheck=false;      
   try 
   {
     //String contactId=ApexPages.currentPage().getParameters().get('UnsubscribeId');
     List<Contact> contactRecords=[SELECT id,Unsubscribe_For_Job_Email_Alert__c,FirstName 
                                  FROM Contact WHERE id=:contactId ];
     if(contactRecords.Size()>0)
     {
        contact=contactRecords[0];
        contact.Unsubscribe_For_Job_Email_Alert__c=true;
        update contact;
     }     
   }
   catch(Exception e)
   {
     validationCheck=true;
     errormsg=e.getMessage();
     system.debug('Error in job email alert unsubscribe page'+e.getMessage());
   }
}

}