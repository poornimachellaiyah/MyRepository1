trigger ReferenceDocumentTrigger on Reference_Document__c (after update,after insert) 
{
     
     for (Reference_Document__c r: Trigger.new)
         {
            ReferenceDocumentTriggerHandler.getHandler().execute();
         }
    

}