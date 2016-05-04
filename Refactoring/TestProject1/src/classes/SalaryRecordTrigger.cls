/* Narpavi-TPT-Salary Changes-(30/5/15)
  Class created to fix the currency value from previous salary 
  record when a new salary record is created 
  
******************************************************************   
 Change log:Code Streamlining. Search Tag : TPT-(29-Oct-2015)
                        
****************************************************************** 
*/ 

public without sharing class SalaryRecordTrigger
{

   private SalaryRecordTrigger(){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }
    
     public static SalaryRecordTrigger getHandler(){
        if(handler == null){
            handler = new SalaryRecordTrigger();
        }
        return handler;
    }
    
    private static SalaryRecordTrigger handler;
    
    
     public void execute(){
        if(trigger.isBefore){
            if(trigger.isInsert)
            {
                 updateSalaryCurrencyRecord();  
            }
           
    }
  }
  
  //Update the currecncy field in salary record from the previous salary record
  //Narpavi-TPT-(29-Oct-2015)-(SS-4694129)-Code Streamlining
  //Streamline the select statement 
  public void updateSalaryCurrencyRecord()
  {
            
        List<fHCM2__Salary__c> salary=trigger.new;             //TPT-(29-Oct-2015)    
        List<fHCM2__Salary__c> salRecordToUpdate = new list<fHCM2__Salary__c>();    
                       
        //Getting the currecy field from previous salary record 
        fHCM2__Employment__c emp = new fHCM2__Employment__c();
        List <fHCM2__Employment__c> employ = [select id,fHCM2__Current_Salary__r.id,fHCM2__Current_Salary__r.fHCM2__Active__c,fHCM2__Current_Salary__r.CURRENCY_SALARY__c from fHCM2__Employment__c where id=:salary[0].fHCM2__Employment__c AND fHCM2__Current_Salary__r.fHCM2__Active__c=True];        
        if(employ.size()>0)
        {
            emp=employ[0];  
        } 
        
        //Getting the currency field from HR request record
        fHCM2__HR_Request__c hr = new fHCM2__HR_Request__c();
        List<fHCM2__HR_Request__c> hrquest = [select id,fHCM2__Employment__r.id,S_CURRENCY_SALARY__c from fHCM2__HR_Request__c where fHCM2__Employment__r.id=:salary[0].fHCM2__Employment__c];
        if(hrquest.size()>0)
        {
            hr=hrquest[0];
        }

         for(fHCM2__Salary__c sal:salary)        
         {
            if(emp.fHCM2__Current_Salary__c!=null && hr.S_CURRENCY_SALARY__c == null)
            {           
                sal.CURRENCY_SALARY__c = emp.fHCM2__Current_Salary__r.CURRENCY_SALARY__c;
                salRecordToUpdate .add(sal);             
            }
          }
            try
            {
                if(salRecordToUpdate.size()>0 )
                update salRecordToUpdate ;
            }
            catch (DMLException e) 
            {
                string errMsg=string.valueOf(e);
                string ValidationMessage;
                if(errMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) 
                {
                    ValidationMessage = errMsg.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                    trigger.new[0].addError(ValidationMessage);     
                }
                else
                   trigger.new[0].addError(e);    
            }    
  }   
       
     private static boolean trueFirstTimeOnly = true;
    
    // static function will only return true once in each transaction
    // used to avoid trigger recursion
    // see http://help.salesforce.com/apex/HTViewSolution?id=000133752&language=en_US
    public static boolean runOnce(){
        if(trueFirstTimeOnly){
            trueFirstTimeOnly = false; 
            return true;
        }else{
            return false;
        }
    }
    
    // for testing
    public static void ClearRunOnce()
    {
        trueFirstTimeOnly = true;
    }

}