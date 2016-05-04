@isTest
private class JobEmailAlertUnsubscribeControllerTest{

static testMethod void testUpdateContactFields() 
{
    String testEmail = 'test_' + System.now().getTime() + '@test.com';
    Contact testContact = new Contact( Salutation = 'Mr.',FirstName = 'test_fn', 
                                       LastName = 'test_ln',Email = testEmail, 
                                       MobilePhone = '1234',MailingCountry = 'Zimbabwe',
                                       Consent_To_Information_Being_Stored__c = true,
                                       npe01__PreferredPhone__c = 'Mobile',
                                       npe01__Preferred_Email__c = 'Personal'                                                                           
                                       );
    insert testContact;
    
    PageReference pageRef = Page.JobEmailAlertUnsubscribePage;
    Test.setCurrentPage(pageRef);
    ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testContact);
    ApexPages.currentPage().getParameters().put('UnsubscribeId',testContact.id);

    
    JobEmailAlertUnsubscribeController ja=new JobEmailAlertUnsubscribeController(sc);
    ja.doUpdateContactField();
}

}