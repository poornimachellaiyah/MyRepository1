/*
* Description:Created for the referee to upload the completed reference request form
* Developer Name : Poornima
* Company        : TPT
* Date created   : 09/09/2015 
* Jira Issue  /Project   : References (SCS-2211)                 
*/
public class UploadReferenceRequestFormController
{
    public String filename{get;set;}
    public transient blob uploadedFile{get;set;}
    public Integer filesize{get; set;}
    public String uploadStatus{get;set;}
    public String errormsg{get;set;}
    public boolean validationCheck{get;set;}
    public OnBoardingCheck__c onboardingcheck{get;set;}
    public Reference_Document__c refDoc {get;set;}
    public String referee {get;set;}
    
    public UploadReferenceRequestFormController()
    {
        String onboardingID=ApexPages.currentPage().getParameters().get('id');
        referee = ApexPages.currentPage().getParameters().get('ref');
        if(onboardingID!=null && onboardingID!= '')
        {
            List<OnBoardingCheck__c> onb = [Select Id,name,Referee_1_First_Name__c,Referee_1_Last_Name__c,Referee_2_First_Name__c,
            Referee_2_Last_Name__c,Alternate_Referee_First_Name__c,Alternate_Referee_Last_Name__c,Application__c,Contact__c,
            Alternate_Referee_Received_Date__c,Reference_1_Received_Date__c,Reference_2_Received_Date__c,Helper_Job_Hiring_Manager__c,
            Helper_PeopleMgr_RecruitmentAdmin_Email__c,Helper_Relationship_Manager_Email__c from OnBoardingCheck__c where id=:onboardingID];
            
            if(onb.size()>0)
            {
               onboardingcheck=onb[0];           
            }
         }
    }
    public PageReference FormSubmit()
    {
        errormsg='';
        validationCheck=false;        
        uploadStatus='';
        
        if (uploadedFile == null)
        {
            errormsg+= '<li>Please attach your reference request form.</li>';
        }
        if(errormsg!=''&& errormsg!=null)
        {
            validationCheck=true;
            system.debug('************errormsg:'+errormsg);
        }
        else
        {
            try
            {
                string name;
                refDoc =new Reference_Document__c();
                if(referee == '1')
                {
                    name=onboardingcheck.Referee_1_First_Name__c +' '+ onboardingcheck.Referee_1_Last_Name__c;
                    onboardingcheck.Reference_1_Received_Date__c=system.today();
                }
                else if(referee == '2')
                {
                    name=onboardingcheck.Referee_2_First_Name__c +' '+ onboardingcheck.Referee_2_Last_Name__c;
                    onboardingcheck.Reference_2_Received_Date__c=system.today();
                }
                else if(referee == '3')
                {
                     name=onboardingcheck.Alternate_Referee_First_Name__c +' '+ onboardingcheck.Alternate_Referee_Last_Name__c;
                     onboardingcheck.Alternate_Referee_Received_Date__c=system.today();
                }    
                refDoc.Referee_Name__c=name;
                refDoc.Reference_Received_Date__c=system.today();
                refDoc.On_Boarding_Check__c=onboardingcheck.id;
                refDoc.Application__c=onboardingcheck.Application__c;
                refDoc.Contact__c=onboardingcheck.Contact__c;
                refDoc.Help_Hiring_Manager_Email__c=onboardingcheck.Helper_Job_Hiring_Manager__c;
                refDoc.Help_People_Manager_Email__c=onboardingcheck.Helper_PeopleMgr_RecruitmentAdmin_Email__c;
                refDoc.Help_Relationship_Manager_Email__c=onboardingcheck.Helper_Relationship_Manager_Email__c;
                insert refDoc;
                update onboardingcheck;
                
                if(uploadedFile!=null)
                {
                    Attachment attach=new Attachment();
                    attach.name=filename;
                    attach.body=uploadedFile;
                    attach.parentid=refDoc.ID;
                    insert attach;              
                }
                uploadStatus='Submitted';      
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