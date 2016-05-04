/* 
* Developer :Narpavi-TPT
* Date:03-Aug-2015 
* Change Search :KE Alumni Phase 3
* Comments:Alumni Accepted for Buddy Programme is checked in Visualforce and save the result in contact record.
*/

public class AgreedInBuddyingContoller
{
  
    public String errormsg{get;set;}
    public boolean validationCheck{get;set;}
    public Contact c {get;set;}
    public boolean HasAccepted {get; set;}
    public String uploadStatus{get;set;}
    public boolean BuddyProgramme=false;
       
    
    public AgreedInBuddyingContoller()
    {
       
       String AppId= ApexPages.currentPage().getParameters().get('ID');
       
       //get the contact record to be update the field Alumni Accepted for Buddy Programme               
       if(AppId!=null && AppId!='')
       {
            List<Contact> con = [Select Id,Alumni_Accepted_for_Buddy_Programme__c from Contact WHERE Id=:AppId];
            if(con.size()>0)
            {
               c=con[0];           
            }
             BuddyProgramme=true; 
    
        }
     }
    
    //Save
    public PageReference FormSubmit()
    {
        errormsg='';
        validationCheck=false;        
        uploadStatus='';
        
        //If check box is not checked error message is displayed
        if (!HasAccepted)
        {
           errormsg+='<li>Confirmation for Buddying Programme is required</li>';
        }                
        if(errormsg!=''&& errormsg!=null)
        {
            validationCheck=true;
            system.debug('errormsg:'+errormsg);
        }
        
        //Check box is checked and updates the contact record 
        else
        {
             try
             {    
                  if(HasAccepted != null && HasAccepted==true)
                  {                                
                           c.Alumni_Accepted_for_Buddy_Programme__c=True;                        
                  }                  
                  uploadStatus='Submitted';
                  update c;   
             }
            catch(exception e)
            {
               validationCheck=true;
               errormsg=e.getMessage();
               System.debug('errormsg:'+errormsg);
            }
        }        
        return null;
    }
}