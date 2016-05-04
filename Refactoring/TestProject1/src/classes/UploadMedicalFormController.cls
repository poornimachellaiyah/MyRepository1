public class UploadMedicalFormController
{
    public String filename{get;set;}
    public transient blob uploadedFile{get;set;}
    public Integer filesize {get; set;}
    public String errormsg{get;set;}
    public boolean validationCheck{get;set;}
    private Boolean showCVMissingMsg;
    public boolean hasPersonalHealthForm;
    public String uploadStatus{get;set;}
    public Application__c application {get;set;}
    public Personal_Health_Information__c personalHealthInfo{get;set;}

    
    public UploadMedicalFormController()
    {
        String appID=ApexPages.currentPage().getParameters().get('appid');        
        List<Application__c> app=[Select Id,name from application__c where id=:appID];         
        if(app.size()>0)
        {
            application=app[0];
        }
        List<Personal_Health_Information__c > phi=[SELECT Id from Personal_Health_Information__c where ApplicationID__c =:appID];
        if(phi.size()>0)
        {
            personalHealthInfo=phi[0];
            hasPersonalHealthForm=true;
        }
        else 
           hasPersonalHealthForm=false;
    }
     public PageReference FormSubmit()
     {
        errormsg='';
        validationCheck=false;
        showCVMissingMsg = false; 
        uploadStatus='';
       
        if (uploadedFile == null && filename != null && filename != '' && !showCVMissingMsg)
        {
            showCVMissingMsg = true;
            errormsg+= '<li>Please re-attach your medical form.</li>';
        }
        else if (uploadedFile == null)
        {
            errormsg+= '<li>Please attach your medical form.</li>';
        }

        if (uploadedFile != null && filename != '' && filesize > 5242880)
            errormsg+= '<li>Please attach a smaller size form: ' + filename + ' (size=' + Decimal.valueOf(filesize/1048576).setScale(0) + 'KB) has exceeded the 5MB limit.</li>';  
        
        if(!hasPersonalHealthForm)
           errormsg+='<li>Personal Health Form should be submitted before uploading the Medical Examination Form</li>';
        
         if(errormsg!=''&& errormsg!=null)
         {
            validationCheck=true;
            system.debug('************errormsg:'+errormsg);
         }
        else
        {              
          if((uploadedFile!=null)&&(hasPersonalHealthForm))
          {
            Attachment attach=new Attachment();
            attach.name=filename;
            attach.body=uploadedFile;
            attach.parentid= personalHealthInfo.ID;
            insert attach;
            uploadStatus='Submitted';
            
            personalHealthInfo.Medical_Form_Uploaded__c=true;
            update personalHealthInfo;
          }
        }     
    
        return null;
     }
}