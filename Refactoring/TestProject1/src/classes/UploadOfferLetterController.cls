/*--------------------------------------------------------------------------------------
   Change Log:E-Volunteer Project     
   Modified date:28 Dec 2015,
   Modified by: Narpavi-TPT,
   Purpose: To find the Offer is E-Volunteer type and set the field in the offer record.
   Search Tag: TPT-(28-Dec-2105) 
----------------------------------------------------------------------------------------- */  
public class UploadOfferLetterController
{
    public String filename{get;set;}
    public transient blob uploadedFile{get;set;}
    public Integer filesize{get; set;}
    public String errormsg{get;set;}
    public boolean validationCheck{get;set;}
    public Offer__c offer {get;set;}
    public boolean HasAccepted {get; set;}
    public boolean HasSigned {get; set;}
    public String uploadStatus{get;set;}
    public boolean ConditionalOffer=false;
    public boolean UnconditionalOffer=false;
    public string recordType{get;set;}
    
    //TPT-(28-Dec-2105)-Added for E-Volunteer
    public string VoluteerType{get;set;}
    public boolean EVolAccepted {get; set;}
    
    public UploadOfferLetterController()
    {
        String ConditionalOfferID=ApexPages.currentPage().getParameters().get('conditionalOfferID');
        String UnconditionalOfferID=ApexPages.currentPage().getParameters().get('unconditionalOfferID'); 
        if(ConditionalOfferID !=null && ConditionalOfferID != '')
        {
            List<Offer__c> ofr = [Select Id,name,RecordType.developername,Conditional_Offer_Response__c,Signed_Offer_Attached__c,Volunteer_Type__c,Health_and_Safety_Acceptance__c from Offer__c where id=:ConditionalOfferID];
            if(ofr.size()>0)
            {
               offer=ofr[0];           
            }
            system.debug('TEST '+offer.RecordType.developername);
            //Dinesh-TPT-Recruit Phase-2 changes-06/July/2015.
            //Find the offer record type 
            recordType=offer.RecordType.developername;
            
            //TPT-(28-Dec-2105):Find the offer is E-Volunteer type 
            VoluteerType=offer.Volunteer_Type__c; 
            ConditionalOffer=true;
        }
        else if(UnconditionalOfferID !=null && UnconditionalOfferID!= '')
        {
            List<Offer__c> ofr = [Select Id,name,RecordType.developername,Unconditional_Offer_Response__c,Signed_Agreement_Attached__c from Offer__c where id=:UnconditionalOfferID];
            if(ofr.size()>0)
            {
               offer=ofr[0];           
            }
            UnconditionalOffer= true;
        }
    }
    public PageReference FormSubmit()
    {
        errormsg='';
        validationCheck=false;        
        uploadStatus='';
        
        if (!HasAccepted)
        {
           errormsg+='<li>Confirm Acceptance of Offer is required</li>';
        }
        
        //TPT-(28-Dec-2105):To display the error message when health and saftey id not checked
        if(offer.Volunteer_Type__c=='E-placement')
        {
           if(!EVolAccepted)
            {
               errormsg+='<li>Health and Safety document is required</li>';
           }
        
        }
        /*if (!HasSigned)
        {
           errormsg+='<li>Signed Offer Letter or Contract Attached is required</li>';
        }       
        if (uploadedFile == null && filename != null && filename != '')
        {
            errormsg+= '<li>Please re-attach your offer letter.</li>';
        }
        else if (uploadedFile == null)
        {
            errormsg+= '<li>Please attach your offer letter.</li>';
        }*/
        if (uploadedFile != null && filename != '' && filesize > 5242880)
           errormsg+= '<li>Please attach a smaller size form: ' + filename + ' (size=' + Decimal.valueOf(filesize/1048576).setScale(0) + 'KB) has exceeded the 5MB limit.</li>';
           
        if(errormsg!=''&& errormsg!=null)
        {
            validationCheck=true;
            system.debug('************errormsg:'+errormsg);
        }
        else
        {
            try
            {
                 if(uploadedFile!=null)
                  {
                        Attachment attach=new Attachment();
                        attach.name=filename;
                        attach.body=uploadedFile;
                        attach.parentid=offer.ID;
                        insert attach;              
                  }
                  if(ConditionalOffer) 
                  {        
                        if(HasAccepted != null && HasAccepted==true)
                            offer.Conditional_Offer_Response__c='Accepted';
                        if(HasSigned!= null && HasSigned==true)
                            offer.Signed_Offer_Attached__c=true;
                            //TPT-(28-Dec-2105):Set the Health and Safety field in offer record                         
                           if(offer.Volunteer_Type__c=='E-placement')
                           {
                                offer.Health_and_Safety_Acceptance__c=true;
                           }
                  }
                  if(UnconditionalOffer)
                  {
                        if(HasAccepted != null && HasAccepted==true)
                            offer.Unconditional_Offer_Response__c='Accepted';
                        if(HasSigned!= null && HasSigned==true)
                            offer.Signed_Agreement_Attached__c=true;
                  }
                  uploadStatus='Submitted';
                  update offer;   
            }
            catch(exception e)
            {
               validationCheck=true;
               errormsg=e.getMessage();
               System.debug('************errormsg:'+errormsg);
            }
        }
        
        return null;
    }
}