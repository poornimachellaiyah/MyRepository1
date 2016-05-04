trigger EmploymentSalaryIntegration on fHCM2__Employment__c (after insert,after update) 
{
   //To inactive the trigger when dataloading is performed
     VSO_Settings__c vso=VSO_Settings__c.getInstance();    
     if(!vso.Trigger_Excute_Check__c)
     { 
        for (fHCM2__Employment__c  er: Trigger.new)
        {
             if(er.fHCM2__Basis__c=='Employee')
            {         
               //if ( SalaryIntegrationHandler.runOnce()) 
               //{            
                 SalaryIntegrationHandler.gethandler().execute();           
               //}
            }
         }     
   }
             
}