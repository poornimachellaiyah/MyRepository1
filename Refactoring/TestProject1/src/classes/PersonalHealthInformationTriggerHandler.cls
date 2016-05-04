/*
******************************************************************   
 Change log:Code Streamlining. Search Tag : TPT-(30-Nov-2015)
                        
****************************************************************** 
*/ 

public without sharing class PersonalHealthInformationTriggerHandler 
{

    public boolean isValid;
    private static PersonalHealthInformationTriggerHandler handler;
    
    private PersonalHealthInformationTriggerHandler()
    {
        isValid=false;
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }
    
    public static PersonalHealthInformationTriggerHandler getHandler()
    {
        if(handler == null)
        {
            handler = new PersonalHealthInformationTriggerHandler();
        }
    return handler;
    }
    
     public void execute()
     {
        if(trigger.isAfter)
        {
            if(trigger.isUpdate)
            {
                this.updateOnboardingFields();
            }
        }
    }
    
  //Narpavi-TPT-(30-Nov-2015)-(SS-4694129)-Code Streamlining
  //Streamline the select statement
  public void updateOnboardingFields()
  {
      List<Personal_Health_Information__c> newHealthInfo= trigger.new;    //TPT-(30-Nov-2015)
                   
      List<OnBoardingCheck__c > onboard=[SELECT id,Medical_Clearance_Progress__c,CreatedDate FROM OnBoardingCheck__c WHERE Application__r.id=:newHealthInfo[0].ApplicationID__c order by CreatedDate desc limit 1];
      if(onboard.Size()>0)
      { 
         for(Personal_Health_Information__c HealthInfo:newHealthInfo)
         {                                                              
             if(HealthInfo.Medical_Form_Uploaded__c)
             {                     
                onboard[0].Medical_Clearance_Progress__c = 'Forms Submitted';
            }                 
        }             
     update onboard;  
     }         
    
  }    

}