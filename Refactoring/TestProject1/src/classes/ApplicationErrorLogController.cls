public with sharing class ApplicationErrorLogController
{
  public Application_Error_Log__c applicationErrorLog{get;set;}

  public void logError(string errClass,string errMsg,string errStack,string errType)
  {
     applicationErrorLog= new Application_Error_Log__c();
     try 
     {
       applicationErrorLog.Exception_Class__c=errClass;
       applicationErrorLog.Exception_Message__c=errMsg;
       applicationErrorLog.Exception_Stack__c=errStack;
       applicationErrorLog.Exception_Type__c=errType;
       insert applicationErrorLog;
     }
     catch(Exception ex)
     {
       system.debug('Error in applicationerrorlog controller'+ex.getmessage());
     }
  }

}