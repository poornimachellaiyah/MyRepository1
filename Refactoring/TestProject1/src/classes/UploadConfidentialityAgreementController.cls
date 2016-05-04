public class UploadConfidentialityAgreementController
{
    //public String filename{get;set;}
    //public transient blob uploadedFile{get;set;}
    //public Integer filesize{get; set;}
    public String errormsg{get;set;}
    public boolean validationCheck{get;set;}
    public OnBoardingCheck__c onboarding{get;set;}
    public boolean HasAccepted {get; set;}   
    public String uploadStatus{get;set;}
    
    
    public UploadConfidentialityAgreementController()
    {
        String OnboardingID=ApexPages.currentPage().getParameters().get('OnboardingID');
        
        if(OnboardingID!=null && OnboardingID!= '')
        {
            List<OnBoardingCheck__c > onboard = [Select Id,name,RecordType.developername,Confidentiality_Agreement_Declaration__c from OnBoardingCheck__c where id=:OnboardingID];
            if(onboard.size()>0)
            {
               onboarding=onboard[0];           
            }            
        }       
    }
    public PageReference FormSubmit()
    {
        errormsg='';
        validationCheck=false;        
        uploadStatus='';
        
        if (!HasAccepted)
        {
           errormsg+='<li>Acceptance of confidentiality agreement declaration is required</li>';
        }               
        /*if (uploadedFile == null && filename != null && filename != '')
        {
            errormsg+= '<li>Please re-attach your offer letter.</li>';
        }
        else if (uploadedFile == null)
        {
            errormsg+= '<li>Please attach your offer letter.</li>';
        }
        if (uploadedFile != null && filename != '' && filesize > 5242880)
           errormsg+= '<li>Please attach a smaller size form: ' + filename + ' (size=' + Decimal.valueOf(filesize/1048576).setScale(0) + 'KB) has exceeded the 5MB limit.</li>';  */
           
        if(errormsg!=''&& errormsg!=null)
        {
            validationCheck=true;
            system.debug('************errormsg:'+errormsg);
        }
        else
        {
        try
        {
         //if(uploadedFile!=null)
         // {
         //   Attachment attach=new Attachment();
         //   attach.name=filename;
         //   attach.body=uploadedFile;
         //   attach.parentid=onboarding.ID;
         //   insert attach;
            uploadStatus='Submitted';  
                    
            if(onboarding.RecordType.DeveloperName=='Employee_Consultant' && HasAccepted != null && HasAccepted==true)
                onboarding.Confidentiality_Agreement_Declaration__c =True;
                
            update onboarding;            
         // }
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