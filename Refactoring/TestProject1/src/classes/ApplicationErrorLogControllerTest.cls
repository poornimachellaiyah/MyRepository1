@isTest
public class ApplicationErrorLogControllerTest{

static testMethod void testApplicationErrorLog()
{
   string errClass='Test Error class';
   string errMsg='Test Error message';
   string errStack='Test Error stack';
   string errType='Test Error type';
   
   ApplicationErrorLogController obj=new ApplicationErrorLogController();   
   obj.logError(errClass,errMsg,errStack,errType);
}


}