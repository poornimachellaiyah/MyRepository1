/*
******************************************************************   
 Change log:Code Streamlining. Search Tag : TPT-(30-Nov-2015)
                        
****************************************************************** 
*/ 

public without sharing class EmploymentrecordTrigger
{

   private EmploymentrecordTrigger(){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }
    
     public static EmploymentrecordTrigger getHandler(){
        if(handler == null){
            handler = new EmploymentrecordTrigger();
        }
        return handler;
    }
    
    private static EmploymentrecordTrigger handler;
    
    
     public void execute(){
        if(trigger.isAfter){
            if(trigger.isInsert)
            {
                            
            }
            else if(trigger.isUpdate)
            {
                updateSalaryfields();
                     
            }   
            if(trigger.isInsert || trigger.isUpdate)              
            {
                 updateEmploymentRecord(); 
            }
        }
        if(trigger.isBefore)
        {
            if(trigger.isUpdate)
            {              
                                              
            }
        }
    }

   //TPT-update the payroll ID from team member in Employment record
   //Narpavi-TPT--(30-Nov-2015)-(SS-4694129)-Code Streamlining   
   //Streamline the select statement    
  public void updateEmploymentRecord()
  {
     
     list<fHCM2__Employment__c> scope=trigger.new;       //TPT-(30-Nov-2015)
     list<fHCM2__Employment__c> empRecordToUpdate=new list<fHCM2__Employment__c> ();
                         
     List<fHCM2__Team_Member__c> teammember1= [SELECT id,fHCM2__Current_Employment__r.Senior_Approver_for_Budget__r.Name,fHCM2__Current_Employment__r.Manager_Employment__r.fHCM2__Email__c,Payroll_ID_Formula__c,fHCM2__Department__r.fHCM2__Policy__r.fHCM2__Hours_Per_Week__c FROM fHCM2__Team_Member__c Where id= :scope[0].fHCM2__Team_Member__c];
       
     fHCM2__Employment__c er=new fHCM2__Employment__c();  
           
      for(fHCM2__Team_Member__c tm:teammember1)
     {
        if(scope[0].fHCM2__Team_Member__c!=null)
        {
             er.id=scope[0].id;
           
              if(scope[0].fHCM2__Basis__c=='Volunteer')               
              {                    
                  er.Payroll_ID__c=tm.Payroll_ID_Formula__c;               
              }                            
              //Poornima-TPT-Salary Changes-(13/3/15)
              //Populating help field with hours_per_week in policy, for the validation rule.                                                
              er.Help_Hours_Per_Week_In_Policy__c=tm.fHCM2__Department__r.fHCM2__Policy__r.fHCM2__Hours_Per_Week__c;    
                   
              //Narpavi-TPT-Salary Changes-(20/3/15)
              //Populating help field with team member email id for emailalert                                          
               er.Help_Manager_Email__c=tm.fHCM2__Current_Employment__r.Manager_Employment__r.fHCM2__Email__c;
                                
               //Narpavi-TPT-Salary Changes-(20/4/15)
               //Populating help field with senior approver for budget from employment for the payflow service.                       
               er.Help_Senior_Budget_Approver_Name__c=tm.fHCM2__Current_Employment__r.Senior_Approver_for_Budget__r.Name;
               empRecordToUpdate.add(er);
                                                             
        }             
     }  
     try
     {                        
        if(empRecordToUpdate.size()>0)
        update empRecordToUpdate;
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
  
   ///Narpavi-TPT-Salary Changes-(16/3/15)
  //Update Salary fields based on FTE change in Employment record
  //Narpavi-TPT-(30-Nov-2015)-(SS-4694129)-Code Streamlining
  //Streamline the select statement and compare the old and new value to set the field     
  public void updateSalaryfields()
  {          
      List<fHCM2__Employment__c> scope=trigger.new;         //TPT-(30-Nov-2015)
      List<fHCM2__Salary__c> salRecordToUpdate= new List<fHCM2__Salary__c>();
      boolean RecordToUpdate=false;        
                   
       fHCM2__Salary__c sal=new fHCM2__Salary__c();
       
       if(scope[0].fHCM2__Current_Salary__c != null)
       {            
          List<fHCM2__Salary__c> salary=[SELECT id,Total_Cost_Excluding_In_Kind_Benefits__c,Country_Bonus__c,Social_Security_Component__c,Other_Statutory_Cont_Component__c,Basic_Annual_Salary__c,Help_Allowances__c,Basic__c,Basic_Salary_Dependents_Medical__c,fHCM2__Amount__c FROM fHCM2__Salary__c WHERE id=:scope[0].fHCM2__Current_Salary__c];   
                    
          for(fHCM2__Employment__c emp:scope) 
          {
             if(salary.size()>0)
             {
                sal=salary[0];
                                         
                 fHCM2__Employment__c oldEmpRecord=(fHCM2__Employment__c)trigger.oldMap.get(emp.id);
                 fHCM2__Employment__c newEmpRecord=(fHCM2__Employment__c)trigger.newMap.get(emp.id);
                                
               if(emp.fHCM2__FTE__c != null&& sal.Basic_Annual_Salary__c !=null)  
               {                   
                   if(oldEmpRecord.fHCM2__FTE__c!= newEmpRecord.fHCM2__FTE__c)
                    {                                                   
                        sal.Basic__c= sal.Basic_Annual_Salary__c*emp.fHCM2__FTE__c;         
                        sal.Basic_Salary_Dependents_Medical__c=(sal.Basic_Annual_Salary__c+(sal.Basic_Annual_Salary__c*0.10))*emp.fHCM2__FTE__c ;                                              
                           
                        if(sal.Help_Allowances__c !=null) 
                        {                        
                          sal.fHCM2__Amount__c=(sal.Basic_Annual_Salary__c+sal.Help_Allowances__c)*emp.fHCM2__FTE__c;                        
                        }
                                                    
                        if(sal.Annual_Gross_Salary__c!=null && sal.Social_Security_Component__c !=null && sal.Other_Statutory_Cont_Component__c !=null) 
                        {
                           sal.Total_Cost_Excluding_In_Kind_Benefits__c=(sal.Annual_Gross_Salary__c+sal.Social_Security_Component__c +sal.Other_Statutory_Cont_Component__c)*emp.fHCM2__FTE__c;                           
                        }
                        RecordToUpdate=true; 
                     }
                }              
               
               //TPT-Narpavi-SCS-1246-(19/6/2015)
               //Populating help field in Salary record with the Employmnet Manager Email id for emailalert                              
               //TPT-(30-Nov-2015)-Changed the code assigning from Contact and below logic is replaced assigning email from User record                           
               if(emp.Manager_Employment__r.fHCM2__User__c !=null)
               {
                 if(oldEmpRecord.Manager_Employment__c!= newEmpRecord.Manager_Employment__c)
                 { 
                     if(emp.Manager_Employment__r.fHCM2__User__r.Email !=null)
                     {
                           sal.Helper_Line_Manager_Email__c=emp.Manager_Employment__r.fHCM2__User__r.Email; 
                           RecordToUpdate=true;            
                     }  
                 }           
              }
                                 
              if(RecordToUpdate)
              salRecordToUpdate.add(sal);               
             }
          }
     try
      {        
        if(salRecordToUpdate.size()>0)
        update salRecordToUpdate;          
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