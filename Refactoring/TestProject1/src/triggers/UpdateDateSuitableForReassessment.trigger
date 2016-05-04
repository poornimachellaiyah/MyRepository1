trigger UpdateDateSuitableForReassessment on Contact (before insert,before update)
{
    for(Contact con:Trigger.new)
    {    
       if(con.Period_Until_Suitable_for_Reassessment__c=='3 Months'&& con.Date_Last_Failed_Selection__c!= null )
           con.Date_Suitable_for_Reassessment__c=con.Date_Last_Failed_Selection__c.addmonths(3);
       if(con.Period_Until_Suitable_for_Reassessment__c=='6 Months'&& con.Date_Last_Failed_Selection__c!= null )
           con.Date_Suitable_for_Reassessment__c=con.Date_Last_Failed_Selection__c.addmonths(6);
       if(con.Period_Until_Suitable_for_Reassessment__c=='12 Months'&& con.Date_Last_Failed_Selection__c!= null )
           con.Date_Suitable_for_Reassessment__c=con.Date_Last_Failed_Selection__c.addmonths(12);
    }
}