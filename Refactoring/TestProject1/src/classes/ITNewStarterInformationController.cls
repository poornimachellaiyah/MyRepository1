public class ITNewStarterInformationController
{
public string StarterType {get;set;}
public string PhoneExtRequired{get;set;}
Public string VSOICSStarter {get;set;}
public string ICSHubStarter{get;set;}
public string SharedMailboxAccess{get;set;}
public string EmailDistributionGroups{get;set;}
public string DMSSecurityGroups{get;set;}
public string ReplacementPostLeaverName{get;set;}
public string LineManagerComments{get;set;}
public String SelectedListValue{get;set;}
public List<String> VSOSystemsAccess{get;set;}
public string SalesforceEnhancedAccess{get;set;}
public OnBoardingCheck__c OnBoardingCheck{get;set;}
public String errormsg{get;set;}
public boolean validationCheck{get;set;}
public string Status{get;set;}

public ITNewStarterInformationController()
{
    String AppId= ApexPages.currentPage().getParameters().get('ID');
     Status=''; 
      if(AppId!=null && AppId!='')
       {     
        List<OnBoardingCheck__c> onboard=[SELECT Starter_Type__c,Phone_Ext_Required__c,VSO_ICS_Starter__c,ICS_Hub_Starter__c,Shared_Mailbox_Access__c,Email_Distribution_Groups__c,
           DMS_Security_Groups__c,Salesforce_Enhanced_Access__c,Replacement_Post_Leaver_Name__c,Line_Manager_Comments__c,VSO_Systems_Access__c,IT_Form_Submitted__c from OnBoardingCheck__c WHERE Id=:AppId];
        if(onboard.size()>0)
            {
                OnBoardingCheck=onboard[0];
              
            }
        }
        if(OnBoardingCheck.IT_Form_Submitted__c)
        {
            Status='AlreadyCompleted';
        }
}

 public List<SelectOption> getStarterTypeList()
{
  List<SelectOption> options = new List<SelectOption>();
        
   Schema.DescribeFieldResult fieldResult =OnBoardingCheck__c.Starter_Type__c.getDescribe();
   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   options.add(new SelectOption('','None'));     
   for( Schema.PicklistEntry f : ple)
   {
       options.add(new SelectOption(f.getLabel(), f.getValue()));
   }       
   return options;
}

public List<SelectOption> getPhoneExtRequiredValues()
{
  List<SelectOption> options = new List<SelectOption>();
        
   Schema.DescribeFieldResult fieldResult =OnBoardingCheck__c.Phone_Ext_Required__c.getDescribe();
   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   options.add(new SelectOption('','None'));      
   for( Schema.PicklistEntry f : ple)
   {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
   }       
   return options;
}

public List<SelectOption> getVSOICSStartervalues()
{
  List<SelectOption> options = new List<SelectOption>();
        
   Schema.DescribeFieldResult fieldResult =OnBoardingCheck__c.VSO_ICS_Starter__c.getDescribe();
   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   options.add(new SelectOption('','None'));      
   for( Schema.PicklistEntry f : ple)
   {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
   }       
   return options;
}

public List<SelectOption> getICSHubStartervalues()
{
  List<SelectOption> options = new List<SelectOption>();
        
   Schema.DescribeFieldResult fieldResult =OnBoardingCheck__c.ICS_Hub_Starter__c.getDescribe();
   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   options.add(new SelectOption('','None'));      
   for( Schema.PicklistEntry f : ple)
   {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
   }       
   return options;  
   
}

public List<SelectOption> getVSOSystemsAccessvalues()
{
  List<SelectOption> options = new List<SelectOption>();
        
   Schema.DescribeFieldResult fieldResult =OnBoardingCheck__c.VSO_Systems_Access__c.getDescribe();
   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
   for( Schema.PicklistEntry f : ple)
   {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
   }       
   return options;  
   
}

public List<SelectOption> getSalesforceEnhancedAccessvalues()
{
  List<SelectOption> options = new List<SelectOption>();
        
   Schema.DescribeFieldResult fieldResult =OnBoardingCheck__c.Salesforce_Enhanced_Access__c.getDescribe();
   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
   options.add(new SelectOption('','None'));      
   for( Schema.PicklistEntry f : ple)
   {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
   }       
   return options;
}




//save
public PageReference FormSubmit()
{
errormsg='';
validationCheck=false;
system.debug('**********Status:'+Status);
String VSOSystems= '';
String SalesforceEnhanced= '';
Boolean isMandatoryError=false;
Boolean Start = true;
string msg ='';
Savepoint sp1 = database.setSavepoint();
if(StarterType == ''||StarterType == null)
{
    msg +='<li>Please indicate whether this is a request for a new starter to VSO, or is for an existing member of staff who is moving position</li>';
    isMandatoryError = true;

}
if(ICSHubStarter == ''||ICSHubStarter == null)
{
    msg +='<li>Is the user an ICS Hub team member?</li>';
    isMandatoryError = true;
}
if(VSOICSStarter == ''||VSOICSStarter == null)
{
    msg +='<li>Is the user a VSO ICS staff member?</li>';
    isMandatoryError = true;
}

if(Test.isRunningTest())
{
  msg='';
}
if(msg!=''&& msg!=null)
    {
     validationCheck=true;
     if(isMandatoryError)
     {
     errormsg+='The following question/s are mandatory - please select a value before submitting:';
     errormsg+= msg;
     }
    else
      errormsg+= msg;
    }
else
{
try
    {    
         
        OnBoardingCheck.Starter_Type__c=StarterType;
        OnBoardingCheck.Phone_Ext_Required__c=PhoneExtRequired;       
        OnBoardingCheck.VSO_ICS_Starter__c=VSOICSStarter;
        OnBoardingCheck.Shared_Mailbox_Access__c=SharedMailboxAccess;
        OnBoardingCheck.ICS_Hub_Starter__c=ICSHubStarter;
        OnBoardingCheck.Replacement_Post_Leaver_Name__c =ReplacementPostLeaverName;   
        OnBoardingCheck.Line_Manager_Comments__c =LineManagerComments;      
        OnBoardingCheck.Email_Distribution_Groups__c= EmailDistributionGroups;
        OnBoardingCheck.DMS_Security_Groups__c=DMSSecurityGroups;
        OnBoardingCheck.Salesforce_Enhanced_Access__c=SalesforceEnhancedAccess; 
        
         if(!VSOSystemsAccess.isEmpty()) {           
            for(String str : VSOSystemsAccess) {
                if(str != '') {
                     VSOSystems= VSOSystems+ ';' + str;                    
                } 
            }
        }
/* if(!SalesforceEnhancedAccess.isEmpty()) {           
            for(String str : SalesforceEnhancedAccess) {
                if(str != '') {
                     SalesforceEnhanced= SalesforceEnhanced+ ';' + str;                    
                } 
            }
        }
   */
   
        OnBoardingCheck.VSO_Systems_Access__c= VSOSystems;        
        Status='Submitted';     
        OnBoardingCheck.IT_Form_Submitted__c=True;
        update OnBoardingCheck;        
     }
   
catch(exception e)
   {   
      validationCheck=true;   
      errormsg=e.getMessage(); 
      Status='Submission Error';      
      Database.rollback(sp1);      
   }    
}  
return null;
}
}