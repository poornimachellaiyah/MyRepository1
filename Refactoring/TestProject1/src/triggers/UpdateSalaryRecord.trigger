trigger UpdateSalaryRecord  on fHCM2__Salary__c (before insert) 
{
 for (fHCM2__Salary__c s: Trigger.new)
{
     if(s.fHCM2__Employment__r.fHCM2__Basis__c=='Employee')
    {
        if ( SalaryRecordTrigger.runOnce()) 
         {            
              SalaryRecordTrigger.gethandler().execute(); 
         }    
    }
    
}
}