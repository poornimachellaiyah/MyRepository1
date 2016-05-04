/* Dinesh Sivalingam-TPT-Salary Changes-(25/3/15)
   Dataloading Functionality - To move the salary related values 
   from the existing fields to the new fields */


Global class FairsailSalaryDataLoadingController implements Database.Batchable<sObject>{

    Global Database.QueryLocator start(Database.BatchableContext BC)
    {
       string query='SELECT id,fHCM2__Basis__c,fHCM2__Team_Member__r.fHCM2__Department__r.fHCM2__Policy__r.fHCM2__Hours_Per_Week__c,fHCM2__Hours_Worked__c FROM fHCM2__Employment__c WHERE fHCM2__Basis__c!=null';   
       return Database.getQueryLocator(query);
    }
    
    Global void execute(Database.BatchableContext BC,List<fHCM2__Employment__c> employmentList)
    {  
        doUpdateSalaryFields(employmentList);
        doUpdateEmploymentFullPartTimeFields(employmentList);
    }
      
    //Method to update the 'Basic_Annual_Salary__c' field in salary object
    private void doUpdateSalaryFields(List<fHCM2__Employment__c> employmentList)
    { 
       //List creation to update a salary record
       List<fHCM2__Salary__c> updateListForSalary=new List<fHCM2__Salary__c>();
       
       try
       {      
           for(fHCM2__Employment__c emp:employmentList)
           {              
                if(emp.fHCM2__Basis__c!=null)
                {                  
                    
                    
                    //Using Employment id get the salary record
                    for(fHCM2__Salary__c salary:[SELECT id,Basic__c,Basic_Annual_Salary__c,fHCM2__Employment__c,Annual_Bonus_of_Basic_Salary__c,Include_Annual_Bonus__c,
                                                 Allowance_1__c,Include_Allowance_1__c,Allowance_1_Fixed_Addition__c,Allowance_1_Increase__c,
                                                 Allowance_2__c,Include_Allowance_2__c,Allowance_2_Fixed_Addition__c,Allowance_2_Increase__c,
                                                 Allowance_3__c,Include_Allowance_3__c,Allowance_3_Fixed_Addition__c,Allowance_3_Increase__c,
                                                 Additional_Payment_1__c,AP1Inc__c,AP1FA__c,Additional_Payment_2__c,AP2Inc__c,AP2FA__c,
                                                 Additional_Payment_4__c,AP4Inc__c,AP4FA__c,Additional_Payment_3__c,Other_Payment_Details__c,Other_Payment_Fixed_Addition__c,
                                                 Other_Payment_Increase__c,Country_Bonus__c  FROM fHCM2__Salary__c WHERE fHCM2__Employment__c=:emp.id ])
                    {
                        //create object to update a salary record
                        fHCM2__Salary__c salaryData=new fHCM2__Salary__c();
                        salaryData.put('id',salary.id);   
                        
                                           
                        salaryData.put('Basic_Annual_Salary__c',salary.Basic__c);
                    
                        //Logic for 'AnnualBonus'                       
                        if((salary.Include_Annual_Bonus__c!=null)&&(salary.Include_Annual_Bonus__c==true))
                        {                         
                            if(salary.Annual_Bonus_of_Basic_Salary__c!=null)
                            {
                                if(salary.Annual_Bonus_of_Basic_Salary__c==8.33333)
                                  salaryData.put('Country_Bonus__c','Yes');                                                   
                                else
                                  salaryData.put('Country_Bonus_Per_Annum__c',salary.Annual_Bonus_of_Basic_Salary__c);                                      
                            }
                        }
                    
                       
                        //Logic for Allowances and Additional payments
                        for(Integer i=1;i<=4;i++)
                        {
                            //Logic for Allowances 1,2,3                         
                            if((i<4)&&(salary.get('Allowance_'+i+'__c')!=null)&&(salary.get('Include_Allowance_'+i+'__c')!=null)&&(salary.get('Include_Allowance_'+i+'__c')==true))
                            {
                                string allowanceValue=string.valueof(salary.get('Allowance_'+i+'__c')).trim().toLowerCase();                                                              
                                if(allowanceValue=='transportation allowance')
                                {                                                                                               
                                    salaryData.put('Transportation_Percentage__c',salary.get('Allowance_'+i+'_Increase__c'));                                     
                                    salaryData.put('Transportation_Additional_Amount__c',salary.get('Allowance_'+i+'_Fixed_Addition__c'));                                                            
                                }
                                
                                else if(allowanceValue=='telephone allowance')
                                {                               
                                    salaryData.put('Telephone_Percentage__c',salary.get('Allowance_'+i+'_Increase__c'));
                                    salaryData.put('Telephone_Additional_Amount__c',salary.get('Allowance_'+i+'_Fixed_Addition__c'));                                                                                 
                                }
                                
                                else if(allowanceValue=='pension allowance')
                                {
                                    salaryData.put('Pension_Allowance_Percentage__c',salary.get('Allowance_'+i+'_Increase__c'));                                   
                                    salaryData.put('Pension_Allowance_Additional_Amount__c',salary.get('Allowance_'+i+'_Fixed_Addition__c'));                                                                                                           
                                }
                                
                                else if(allowanceValue=='dependent medical allowance')
                                {
                                    salaryData.put('Dependent_Medical_Percentage__c','Yes');                                     
                                }
                              
                                else if(allowanceValue=='location allowance')
                                {                            
                                    salaryData.put('Cost_of_Living_Allowance_increase__c',salary.get('Allowance_'+i+'_Increase__c'));                                    
                                    salaryData.put('Cost_of_Living_Allowance_Fixed_Additio__c',salary.get('Allowance_'+i+'_Fixed_Addition__c'));                                                                                                                
                                }
                                
                                else if(allowanceValue=='leave allowance')
                                {
                                    salaryData.put('Leave_Percentage__c',salary.get('Allowance_'+i+'_Increase__c'));
                                    salaryData.put('Leave_Additional_Amount__c',salary.get('Allowance_'+i+'_Fixed_Addition__c'));
                                }
                            }
                        
                            //Logic for Additional payments 1,2,4                            
                            if ((i!=3)&&(salary.get('Additional_Payment_'+i+'__c')!=null))
                            {
                                string additionalValue=string.valueof(salary.get('Additional_Payment_'+i+'__c')).trim().toLowerCase();                                                                                           
                               
                               if(additionalValue=='transportation allowance')
                                {              
                                    salaryData.put('Transportation_Percentage__c',salary.get('AP'+i+'Inc__c'));                                    
                                    salaryData.put('Transportation_Additional_Amount__c',salary.get('AP'+i+'FA__c'));                                                          
                                }
                                else if(additionalValue=='telephone allowance')
                                {                               
                                    salaryData.put('Telephone_Percentage__c',salary.get('AP'+i+'Inc__c'));                                     
                                    salaryData.put('Telephone_Additional_Amount__c',salary.get('AP'+i+'FA__c'));                                                                                   
                                }   
                                else if(additionalValue=='pension allowance')
                                { 
                                    salaryData.put('Pension_Allowance_Percentage__c',salary.get('AP'+i+'Inc__c'));                                    
                                    salaryData.put('Pension_Allowance_Additional_Amount__c',salary.get('AP'+i+'FA__c'));                                                                                                             
                                }                              
                                else if(additionalValue=='market rate adjustment')
                                {                               
                                    salaryData.put('Market_Rate_Adjustment_Increase__c',salary.get('AP'+i+'Inc__c'));                                    
                                    salaryData.put('Market_Rate_Adjustment_Fixed_Addition__c',salary.get('AP'+i+'FA__c'));                                                                            
                                }
                                else if(additionalValue=='additional responsibility')
                                {
                                    salaryData.put('Additional_Responsibility_Percentage__c',salary.get('AP'+i+'Inc__c'));                                     
                                    salaryData.put('Additional_Responsibility_Amount__c',salary.get('AP'+i+'FA__c'));    
                                                                                                         
                                }
                            }
                        }
                    
                        //logic for other additional payments
                        if(salary.Other_Payment_Details__c!=null)                           
                           salaryData.put('Extra_Payment_details__c',salary.Other_Payment_Details__c);                           
                        if(salary.Other_Payment_Fixed_Addition__c!=null)                        
                           salaryData.put('Extra_Payment_Additional_Amount__c',salary.Other_Payment_Fixed_Addition__c);                            
                        if(salary.Other_Payment_Increase__c!=null)                        
                           salaryData.put('Extra_Payment_Percentage__c',salary.Other_Payment_Increase__c);                            
                    
                        if(salaryData!=null)        
                            updateListForSalary.add(salaryData);
                    }        
                }      
           }
       
           if(updateListForSalary.size()>0)
               update updateListForSalary;
       }
       catch(Exception Ex) 
       {
            string errorMsg=Ex.getmessage();
            string errorClass='FairsailDataLoadingController/doUpdateSalaryFields';
            string errorStack=Ex.getStackTraceString();
            string errorType=Ex.getTypeName();
            //log the exception
            ApplicationErrorLogController obj=new ApplicationErrorLogController();
            obj.logError(errorClass,errorMsg,errorStack,errorType);                   
       }     
    }

    //Method to update the 'Full_Time_Part_Time__c' field in EmploymentRecord object
    private void doUpdateEmploymentFullPartTimeFields(List<fHCM2__Employment__c> employmentList)
    { 
        List<fHCM2__Employment__c> updateListForEmp=new List<fHCM2__Employment__c>();
        try
        {
            for(fHCM2__Employment__c emp:employmentList)
            {
                 decimal policyWorkingHour=emp.fHCM2__Team_Member__r.fHCM2__Department__r.fHCM2__Policy__r.fHCM2__Hours_Per_Week__c;
            
                 if((emp.fHCM2__Hours_Worked__c!=null)&&(policyWorkingHour!=null)&&(emp.fHCM2__Basis__c!='Volunteer'))
                 {
                     //Create object to update a Employment record
                     fHCM2__Employment__c empRecord=new fHCM2__Employment__c();
                     empRecord.id=emp.id;
                    
                     //compare the working hours in 'employment' and 'policy' record
                     if(emp.fHCM2__Hours_Worked__c==policyWorkingHour)
                     {                 
                        empRecord.Full_Time_Part_Time__c='Full Time';                                            
                     }
                     else
                     {
                        empRecord.Full_Time_Part_Time__c='Part Time';                       
                     }                    
                     updateListForEmp.add(empRecord);
                 }
            }
    
            if(updateListForEmp.size()>0)
                update updateListForEmp;
        }
        catch(Exception Ex) 
        {
            string errorMsg=Ex.getmessage();
            string errorClass='FairsailDataLoadingController/doUpdateEmploymentFullPartTimeFields';
            string errorStack=Ex.getStackTraceString();
            string errorType=Ex.getTypeName();
            //log the exception
            ApplicationErrorLogController obj=new ApplicationErrorLogController();
            obj.logError(errorClass,errorMsg,errorStack,errorType);                   
        } 
    }

    Global void finish(Database.BatchableContext BC){}   
}