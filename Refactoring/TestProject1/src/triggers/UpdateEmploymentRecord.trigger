trigger UpdateEmploymentRecord on fHCM2__Employment__c (after update,after insert) 
{
     //To inactive the trigger when dataloading is performed
     VSO_Settings__c vso=VSO_Settings__c.getInstance();    
     if(!vso.Trigger_Excute_Check__c)
    {
      if (EmploymentrecordTrigger.runOnce()) 
      {
          for (fHCM2__Employment__c er: Trigger.new)
          {                      
                EmploymentrecordTrigger.getHandler().execute();
            }
        }
     }
}