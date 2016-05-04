/*
* Description:Created for sending reference request email to the referee on clicking the send referee email button
* Developer Name : Poornima
* Company        : TPT
* Date created   : 07/09/2015
* Jira Issue  /Project   : References (SCS-2211)                 
*/

public class Onboarding_SendRefereeEmailController
{
    public Integer referee{get;set;}
    public string form{get;set;}
    public boolean attachJobdoc{get;set;}
    public OnBoardingCheck__c onboard {get;set;}
    public Contact tempcontact{get;set;}
    public String emailStatus{get;set;}
    public string refereeURL{get;set;}
    public string errormsg{get;set;}
    public boolean validationCheck{get;set;}
    public boolean skipTest{get;set;}
    
    public Onboarding_SendRefereeEmailController()
    {
        onboard=new OnBoardingCheck__c(); 
        skipTest=false;       
        String OnboardingId = ApexPages.currentPage().getParameters().get('id');
        if(OnboardingId !=null && OnboardingId !='')
        {
            List<OnBoardingCheck__c> onb=[select id,Referee_1_First_Name__c,Referee_1_Last_Name__c,Referee_2_First_Name__c,Referee_2_Last_Name__c,
            Alternate_Referee_First_Name__c,Alternate_Referee_Last_Name__c,Referee_1_Email__c,Referee_2_Email__c,Alternate_Referee_Email__c,
            Application__r.job__r.id,Contact__r.id,Alternate_Referee_Sent_Date__c,Reference_1_Sent_Date__c,
            Reference_2_Sent_Date__c,Job_Country__c,Upload_Reference_Request_Form_Link__c from OnBoardingCheck__c where id=:OnboardingId ];
            
            if(onb.size()>0)
            {
                onboard=onb[0];
            }
        }    
    }
    
    public PageReference SendEmail()
    {
        boolean hasDoc=false;
        emailStatus='';   
        errormsg='';   
        validationCheck=false;    
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(referee==1)
        {    
            if(onboard.Referee_1_First_Name__c==null)
                errormsg+='<li>Referee 1 does not have a firstname</li>';
            if(onboard.Referee_1_Last_Name__c==null)
                errormsg+='<li>Referee 1 does not have a lastname</li>';
            if(onboard.Referee_1_Email__c==null)
                errormsg+='<li>Referee 1 does not have an email</li>';
            if(errormsg==''|| errormsg==null)
            {
                refereeURL=onboard.Upload_Reference_Request_Form_Link__c+'?ref='+referee+'&id='+onboard.Id;      
                tempcontact=new Contact(FirstName=onboard.Referee_1_First_Name__c,LastName=onboard.Referee_1_Last_Name__c,Email=onboard.Referee_1_Email__c,Help_RefereeFormUploadLink__c=refereeURL);
                insert tempcontact;
                onboard.Reference_1_Sent_Date__c=system.today(); 
            }           
        }            
        if(referee==2)
        {  
            if(onboard.Referee_2_First_Name__c==null)
                errormsg+='<li>Referee 2 does not have a firstname</li>';
            if(onboard.Referee_2_Last_Name__c==null)
                errormsg+='<li>Referee 2 does not have a lastname</li>';
            if(onboard.Referee_2_Email__c==null)
                errormsg+='<li>Referee 2 does not have an email</li>';
            if(errormsg==''|| errormsg==null)
            {   
                refereeURL=onboard.Upload_Reference_Request_Form_Link__c+'?ref='+referee+'&id='+onboard.Id;      
                tempcontact=new Contact(FirstName=onboard.Referee_2_First_Name__c,LastName=onboard.Referee_2_Last_Name__c,Email=onboard.Referee_2_Email__c,Help_RefereeFormUploadLink__c=refereeURL);
                insert tempcontact;
                onboard.Reference_2_Sent_Date__c=system.today();
            }            
        }
        if(referee==3)
        {   
            
            if(onboard.Alternate_Referee_First_Name__c==null)
                errormsg+='<li>Alternate Referee does not have a firstname</li>';
            if(onboard.Alternate_Referee_Last_Name__c==null)
                errormsg+='<li>Alternate Referee does not have a lastname</li>';
            if(onboard.Alternate_Referee_Email__c==null)
                errormsg+='<li>Alternate Referee does not have an email</li>';
            if(errormsg==''|| errormsg==null)
            {        
                refereeURL=onboard.Upload_Reference_Request_Form_Link__c+'?ref='+referee+'&id='+onboard.Id;
                tempcontact=new Contact(FirstName=onboard.Alternate_Referee_First_Name__c,LastName=onboard.Alternate_Referee_Last_Name__c,Email=onboard.Alternate_Referee_Email__c,Help_RefereeFormUploadLink__c=refereeURL);
                insert tempcontact;
                onboard.Alternate_Referee_Sent_Date__c=system.today();
            }
        }  
        
       
        //Choose template based on user selection     
        if(attachJobdoc & form.toLowerCase().contains('volunteer'))
        {
        
           EmailTemplate template = [select id, name from EmailTemplate where developername ='Volunteer_Referee_Email_Template'];
           if(template != null)
               message.setTemplateId(template.id);
           else
               errormsg+='Template Does not Exist';
        }
        else if(!attachJobdoc & form.toLowerCase().contains('volunteer'))
        {
           EmailTemplate template = [select id, name from EmailTemplate where developername ='Volunteer_Referee_Email_Without_Job_Description_Document_Template'];
           if(template != null)
               message.setTemplateId(template.id);
           else
               errormsg+='Template Does not Exist';             
        }
        else if(attachJobdoc & form.toLowerCase().contains('employee'))
        {
           EmailTemplate template = [select id, name from EmailTemplate where developername ='Employee_Referee_Email_Template'];
           if(template != null)
               message.setTemplateId(template.id); 
           else
               errormsg+='Template Does not Exist';            
        }
        else if(!attachJobdoc & form.toLowerCase().contains('employee'))
        {
           EmailTemplate template = [select id, name from EmailTemplate where developername ='Employee_Referee_Email_Without_Job_Description_Document_Template'];
           if(template != null)
               message.setTemplateId(template.id);
           else
               errormsg+='Template Does not Exist';             
        }
        
        //Attach job description document
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        if(attachJobdoc)
        {            
            for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :onboard.Application__r.job__r.id])
            {
                string filename=a.Name;           
                if(filename.toLowerCase().contains('vsojd'))
                {
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(a.Body);
                    fileAttachments.add(efa); 
                    hasDoc=true;              
                }
            }
        }       
       
        //Select the reference request document to send.
        if(!skipTest){
        Document doc = [select id,name,body,contenttype,developername,type from Document where developername =:form];
        if(doc!=null)
        {
            Messaging.Emailfileattachment refDoc = new Messaging.Emailfileattachment();
            refDoc.setFileName(doc.developerName+'.'+doc.type);
            refDoc.setContentType(doc.contentType);
            refDoc.setBody(doc.Body);
            fileAttachments.add(refDoc);
               
        }}
            
        message.setFileAttachments(fileAttachments);
        
        if(attachJobdoc && !hasDoc)
            errormsg+='The system cannot find a job description on the associated job record (a document with ‘VSOJD’ in its title). Please attach the job description to the job record before sending or untick the checkbox to send email without job description document and try again.';
        
        if(errormsg!=null && errormsg!='')
        {
            validationCheck=true;
        }  
        else
        { 
            message.saveAsActivity = true;
            message.setTargetObjectId(tempcontact.Id);
            message.setWhatId(onboard.Id);
            try
            {
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{message});
                if (results[0].isSuccess())
                {
                    emailStatus='sent';
                    update onboard;
                }
             }
            catch(Exception e)             
             {
               System.debug('Email failed to send:'+e.getMessage());        
             }
             delete tempcontact;         
        }        
        
        return null;
    }
    
    public PageReference Cancel()
    { 
        string pageurl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + onboard.id;
        PageReference page =new PageReference(pageurl);
        page.setRedirect(True);
        return page;
    }  
   
    
}