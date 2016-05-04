public class Job_DetailsPageController{
    public Job__c jobRec {get;set;}
    public String attachmentURL{get;set;}
    public String attachmentId{get;set;}
    public String filename{get;set;}
    
    private Map<string, VSO_Site_Settings__c> mapVSOSiteSettings;
    
    public Job_DetailsPageController(Apexpages.standardcontroller controller){
        this();
    }
    public Job_DetailsPageController(){
         mapVSOSiteSettings = VSO_Site_Settings__c.getAll();
         attachmentURL='';
         String JobId = ApexPages.currentPage().getParameters().get('jid');
         if(JobId!=null && JobId!=''){
            list<Job__c> joblist = [Select Job_Title__c,Help_Type__c,Desk_Space_Location__c,Projected_Start_Date__c ,
                    (select id,name from Attachments where IsPrivate=false AND Name like:'%VSOJD%' order by LastmodifiedDate DESC Limit 1),
                   Projected_End_Date__c,Job_Status__c,Job_Reason__c,Update_Job_Status__c,Actual_Start_Date__c,Actual_End_Date__c,
                   Primary_Work_Town_City__c, Country__c,Country__r.name, Contract_Type__c, Contract_Length__c,Full_Or_Part_Time__c,
                   Working_Hours_Per_Week__c, Application_Closing_Date__c,Advertised_Salary__c,Role_Overview__c,Introduction_to_VSO__c,
                   Ideal_Applicant_Summary__c,How_To_Apply__c, Advertised_Job_Start_Date__c, Advertised_Interview_Date__c,
                   Advertise_Internally__c,Advertise_Externally__c,Additional_Advert_Text__c,Projected_Duration_Weeks__c, Advertised_Project_Duration__c,
                   Employer__c,Employer__r.name,Use_Senior_Roles_Application_Form__c  From Job__c where Id=:JobId];
            
            if(joblist.size()>0){
                jobRec=joblist[0];
                if(jobRec.Attachments.size()>0){
                    attachmentURL='/servlet/servlet.FileDownload?file='+jobRec.Attachments[0].id;
                    filename=jobRec.Attachments[0].name;
                    attachmentId=jobRec.Attachments[0].id;
                }
            }    
         }
         
    }

    public boolean getShowHeaderandSidebar(){
        return (Utility.getProfileName(Userinfo.getProfileId())!='Job Opportunities Sites Profile');
    }
    
    //Dinesh-TPT-RecruitV2 changes-08/June/2015.
    //Method changed to navigate the user to the appropriate application page based on the job type
    public pagereference Applytojob(){
        if((jobRec.Help_Type__c=='Employee') && (jobRec.Use_Senior_Roles_Application_Form__c!=false)){           
             pageReference pg1=page.Job_SeniorRoleApplicationPage;   
             pg1.getparameters().put('jid',jobRec.id);
             pg1.setRedirect(true);         
             return pg1;            
        }
        else if (jobRec.Help_Type__c=='Corporate'){
             pageReference pg2=page.Job_KnowledgeExchangeApplicationPage;   
             pg2.getparameters().put('jid',jobRec.id);
             pg2.setRedirect(true);         
             return pg2;        
        }
        else{
            pageReference  pg=page.Job_ApplicationPage;            
            pg.getparameters().put('jid',jobRec.id);
            pg.setRedirect(true);
            return pg;
        }
    }

    public String gettargetURL()
    {
        String workTargetURL = '';
                    
        pageReference pg=page.Job_ApplicationPage;
        pg.getparameters().put('jid',jobRec.id);
        pg.setRedirect(true);
        
        if (mapVSOSiteSettings != null && mapVSOSiteSettings.containsKey('Job Opportunities'))
        {
            VSO_Site_Settings__c workVSOSiteSetting;
            workVSOSiteSetting = mapVSOSiteSettings.get('Job Opportunities');
            workTargetURL = workVSOSiteSetting.Site_URL__c;
            if  (workVSOSiteSetting.Site_Path__c != null)
            {
                workTargetURL += workVSOSiteSetting.Site_Path__c;
            }
        }
                
        workTargetURL += pg.getUrl().replace('/apex','');

        return workTargetURL;
    }
        
}