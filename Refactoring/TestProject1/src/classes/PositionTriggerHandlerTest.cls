@isTest
private class PositionTriggerHandlerTest {

    static testMethod void testInsertPosition() {
        
        Country__c thecountry = TestDataClass.getCountry('United Kingdom');
        insert thecountry;
                           
        Job__c thejob = TestDataClass.getJob('Employee_Job');
        thejob.Country__c = thecountry.Id;
        thejob.Job_Status__c = 'Approved for Recruitment';
        thejob.Advertise_Internally__c = true;
        thejob.Responsible_To__c = Utility.getRandomString(10);
        insert thejob;
        
        Contact thecontact = TestDataClass.getContact('Employee');
        insert thecontact;
        
        Application__c theapplication = TestDataClass.getApplication();
        theapplication.Applicant__c = thecontact.Id;
        theapplication.Job__c = thejob.Id;
        insert theapplication;
        
        Offer__c theoffer = TestDataClass.getOffer('Volunteer_Offer');
        theoffer.Applicant__c = thecontact.Id;
        theoffer.Application__c = theapplication.Id;
        //Amended by TPT-1597 Payroll office mandatory for employee offer
        theoffer.Payroll_Office_processing_location__c=thecountry.id;
        theoffer.Offer_Status__c='Conditional Offer Accepted';
        insert theoffer;
       
        Position__c theposition = TestDataClass.getPosition('Employee_Position');
        theposition.Contact__c = thecontact.Id;
        theposition.Offer__c = theoffer.Id;
        insert theposition; 
        
    
  }
}