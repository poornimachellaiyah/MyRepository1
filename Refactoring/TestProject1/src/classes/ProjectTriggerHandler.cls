/*
* Description:Insert grants when new project is created
* Developer Name : Poornima
* Company        : TPT
* Date created   : 16/02/2016
* Jira Issue  /Project   : VSO People - Timesheets                
*/

public class ProjectTriggerHandler
{
    private ProjectTriggerHandler()
    {
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');}
    }

    public void execute()
    {
         if(trigger.isAfter){
              if(trigger.isInsert){
              createGrants();
              }
              if(trigger.isUpdate){              
              }    
         }
               
    }
    
    public void createGrants()
    {
        List<Grant__c> grantToInsert = new List<Grant__c>();
        List<VSO_Project__c> lstprojects=trigger.new;
        for(VSO_Project__c project:lstprojects)
        {
            Grant__c grant1=new Grant__c(Name='# UNRESTRICTED FUNDS',Active__c=true,Grant_Name__c='Unrestricted Funds',Description__c='TBD',VSO_Project__c=project.id);
            Grant__c grant2=new Grant__c(Name='Strategic Funds',Active__c=true,Grant_Name__c='Unrestricted Funds',Description__c='TBD',VSO_Project__c=project.id);
            grantToInsert.add(grant1); 
            grantToInsert.add(grant2);            
        }
        if(grantToInsert!=null){insert grantToInsert;}
    }
    
    private static ProjectTriggerHandler handler;
    public static ProjectTriggerHandler getHandler(){
        if(handler == null){
            handler = new ProjectTriggerHandler();
        }
    return handler;
    }
}