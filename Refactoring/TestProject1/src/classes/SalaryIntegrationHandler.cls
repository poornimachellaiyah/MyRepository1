/* Narpavi-TPT-Salary Changes-(12/3/15)
   when an employmnet record created 
   Salary record are created by integration process 
******************************************************************   
 Change log: Changes made to this class for fixing/stopping New Salary records  
             being created for Volunteer, Employee and Others 
             when Recalculate Visibility button in HR Department is
             Clicked. Search Tag : RR-18-12-2015
             
             Changed logic to populate email address helper field to reference User
             not Contact record
             Search Tag : LN-23-12-2015
             
             Change made by Narpavi to fix the current salary in employment record for Continuing Service of an Employee
             Search Tag:TPT-16-2-2016  
******************************************************************   
   */

public without sharing class SalaryIntegrationHandler 
{

//New Variable Added to Check Trigger is Insert Or Update 
   Boolean IsNewEmployment;                                              //RR-18-12-2015
 
    private SalaryIntegrationHandler (){
        if(!trigger.isExecuting){
            throw new InternalException('Not in Trigger context!');
        }
    }
    
          
     public void execute(){
        if(trigger.isafter){
            if(trigger.isInsert)
            {                 
                 IsNewEmployment = true;                                 //RR-18-12-2015
                 createdSalaryRecord(IsNewEmployment);                   //RR-18-12-2015(Included Variable for this method)
            }
            if(trigger.isUpdate)
            {
                if(runOnce())
                {
                    IsNewEmployment = false;                                //RR-18-12-2015
                    createdSalaryRecord(IsNewEmployment);                   //RR-18-12-2015 (Included Variable for this method) 
                }
            }
           
    }
  }

    public void createdSalaryRecord(boolean IsNewEmployment)
    {
        system.debug('CreatedSalaryRecord');           
        //Retrieve salary fields from employment record                             
        fHCM2__Employment__c emp = new fHCM2__Employment__c();   
        List<fHCM2__Employment__c> emplist = [select id,fHCM2__Basis__c,IsCreateNewSalary__c,Manager_Employment__r.VSO_Recruit_Contact_Record__c,Manager_Employment__r.fHCM2__User__r.Email,fHCM2__Current_Salary__r.id
        ,fHCM2__Current_Salary__r.fHCM2__Currency__r.id,fHCM2__Team_Member__r.fHCM2__Department__r.fHCM2__Policy__r.id,On_Boarding_Record__r.Confirmed_Start_of_Service_Date__c,On_Boarding_Record__r.Application__r.id
        ,On_Boarding_Record__r.Application__r.Help_Offer__c,Is_Continuing_Employee_Service__c,fHCM2__Current_Salary__c from fHCM2__Employment__c where id IN:trigger.new];   //LN-23-12-15

        if(emplist.size()>0)
        {
            emp=emplist[0];
        }                                               
        
        //Getting the offer record related to the onboarding linked to the employment record
        Offer__c ofr = new Offer__c();
        //TPT-Poornima changed the where condition to get the recent offer for the application
        //Added allowance fields for Emp-O&O changes
        List<Offer__c> offer = [select id,Application__r.id,Salary_Currency__c,RecordType.DeveloperName,
        Additional_Responsibility__c,Additional_Responsibility_FTE_amount__c,Cost_of_Living_Allowance__c,Cost_of_Living_Allowance_FTE_amount__c,
        Country_Bonus_Per_Annum__c,Country_Bonus_One_Month_Per_Annum__c,Country_Bonus_Description__c,Extra_Payment__c,Extra_Payment_FTE_amount__c,Dependant_Medical__c,
        Leave_Allowance__c,Leave_Allowance_FTE_amount__c,Leave_Travel_Allowance__c,Leave_Travel_Allowance_FTE_amount__c,Market_Rate_Adjustment__c,
        Market_Rate_Adjustment_FTE_amount__c,Pension_Allowance__c,Pension_Allowance_FTE_amount__c,Telephone_Allowance__c,Telephone_Allowance_FTE_amount__c,
        Transportation_Allowance__c,Transportation_Allowance_FTE_amount__c,Annual_Basic_Salary_FTE__c,Annual_FTE_Gross_Salary__c from Offer__c where id=:emp.On_Boarding_Record__r.Application__r.Help_Offer__c];                               
        
        if(offer.size()>0)
        {
            ofr=offer[0];
        } 
        //If employment record does not have the salary record then create new salary record
        //OR
        //Poornima-TPT-SCS-1309-(5-Oct-2015)
        //If the employee have continuing employee service when they are moving between employee positions without a break in service create a new salary record.
        //if(emp.fHCM2__Current_Salary__r.id == null || emp.IsCreateNewSalary__c)                     //RR-18-12-2015
        //Commented the above if statement and add the below if statement , By Raghu 18/12/2015       //RR-18-12-2015          
          if(emp.fHCM2__Basis__c == 'Employee' && (IsNewEmployment || emp.IsCreateNewSalary__c))      //RR-18-12-2015
        {           
            system.debug('CreatedSalaryRecord Before Salary Assignment');
            fHCM2__Salary__c s = new fHCM2__Salary__c();
            s.fHCM2__Employment__c= emp.Id;
            s.fHCM2__Active__c = True;
            s.fHCM2__Change_Reason__c = 'Starting salary';            
            s.fHCM2__Start_Date__c = emp.On_Boarding_Record__r.Confirmed_Start_of_Service_Date__c; 
            s.CURRENCY_SALARY__c = ofr.Salary_Currency__c;                             
            s.Annual_Gross_Salary__c= ofr.Annual_FTE_Gross_Salary__c;             
                                          
            //TPT-Narpavi-SCS-1246-(13/5/2015)
            //Populating help field in Salary record with the Employmnet Manager Email id from contact record for emailalert
            
            /* //LN-23-12-2015
            if(emp.Manager_Employment__r.VSO_Recruit_Contact_Record__c !=null)
            {
                 if(emp.Manager_Employment__r.VSO_Recruit_Contact_Record__r.npe01__WorkEmail__c !=null)
                 {
                   s.Helper_Line_Manager_Email__c=emp.Manager_Employment__r.VSO_Recruit_Contact_Record__r.npe01__WorkEmail__c;           
                 }             
                 else if(emp.Manager_Employment__r.VSO_Recruit_Contact_Record__r.npe01__HomeEmail__c !=null)
                  {
                   s.Helper_Line_Manager_Email__c=emp.Manager_Employment__r.VSO_Recruit_Contact_Record__r.npe01__HomeEmail__c;  
                  }
              
            }   
            */ //LN-23-12-2015
            
            //LN-23-12-2015 Commented out code above assigning email from User record and added replacement 
            //logic below assigning from Contact

            if(emp.Manager_Employment__r.fHCM2__User__c !=null)
            {
                 if(emp.Manager_Employment__r.fHCM2__User__r.Email !=null)
                 {
                   s.Helper_Line_Manager_Email__c=emp.Manager_Employment__r.fHCM2__User__r.Email;           
                 }             
            }
 
             //TPT-Poornima- Added the below code to autofill the allowance fields in salary record from the offer record - dated 17/11/2015
            s.Additional_Responsibility_Percentage__c=ofr.Additional_Responsibility__c;
            s.Additional_Responsibility_Amount__c=ofr.Additional_Responsibility_FTE_amount__c;
            s.Country_Bonus_Per_Annum__c=ofr.Country_Bonus_Per_Annum__c;
            s.Country_Bonus__c=ofr.Country_Bonus_One_Month_Per_Annum__c;
            s.Annual_Bonus__c=ofr.Country_Bonus_Description__c;
            s.Cost_of_Living_Allowance_increase__c=ofr.Cost_of_Living_Allowance__c;
            s.Cost_of_Living_Allowance_Fixed_Additio__c =ofr.Cost_of_Living_Allowance_FTE_amount__c;
            s.Dependent_Medical_Percentage__c=ofr.Dependant_Medical__c;
            s.Extra_Payment_Percentage__c=ofr.Extra_Payment__c;
            s.Extra_Payment_Additional_Amount__c=ofr.Extra_Payment_FTE_amount__c;
            s.Leave_Percentage__c=ofr.Leave_Allowance__c;
            s.Leave_Additional_Amount__c=ofr.Leave_Allowance_FTE_amount__c;
            s.Leave_Travel_Percentage__c=ofr.Leave_Travel_Allowance__c;
            s.Leave_Travel_Additional_Amount__c=ofr.Leave_Travel_Allowance_FTE_amount__c;
            s.Market_Rate_Adjustment_Increase__c=ofr.Market_Rate_Adjustment__c;
            s.Market_Rate_Adjustment_Fixed_Addition__c=ofr.Market_Rate_Adjustment_FTE_amount__c;
            s.Pension_Allowance_Percentage__c=ofr.Pension_Allowance__c;
            s.Pension_Allowance_Additional_Amount__c=ofr.Pension_Allowance_FTE_amount__c;
            s.Telephone_Percentage__c=ofr.Telephone_Allowance__c;
            s.Telephone_Additional_Amount__c=ofr.Telephone_Allowance_FTE_amount__c;
            s.Transportation_Percentage__c=ofr.Transportation_Allowance__c;
            s.Transportation_Additional_Amount__c=ofr.Transportation_Allowance_FTE_amount__c;
            s.Basic_Annual_Salary__c=ofr.Annual_Basic_Salary_FTE__c;         
            
            system.debug('CreatedSalaryRecord Before Salary Insert');    
            
      
                                                            
            insert s;
                       
            system.debug('CreatedSalaryRecord After Salary Assignment');
            emp.IsCreateNewSalary__c=false;
            //TPT-16-2-2016 - Set the current salary in employment record
            if(emp.Is_Continuing_Employee_Service__c=='Continuing Employee') 
            {
                emp.fHCM2__Current_Salary__c=s.id;
            }                                 
            update emp;
        }                           
              
    }
           
    public static SalaryIntegrationHandler  getHandler(){
        if(handler == null){
            handler = new SalaryIntegrationHandler ();
        }
        return handler;
    }
     private static SalaryIntegrationHandler handler;    
    
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