@isTest
private class CountryTriggerHandlerTest {

	static testMethod void testCountryCreate(){				
		Country__c thecountry = TestDataClass.getCountry('United Kingdom');
		insert thecountry;
		system.assertEquals([SELECT count() FROM Country__c],1);
	}
	
	static testMethod void testChangePeople(){
		
		Country__c thecountry = TestDataClass.getCountry('United Kingdom');
		insert thecountry;
		
		Id newuser = [SELECT Id FROM User WHERE UserRoleId!='' 
												AND isActive=true 
												AND Id!=:thecountry.Country_Director__c 
												AND Id!=:thecountry.Country_People_Manager__c LIMIT 1].Id;
			
		// Modify the Country People Manager
		thecountry.Country_People_Manager__c = newuser;		
		update thecountry;
		// Modify the Country Director
		thecountry.Country_Director__c = newuser;
		update thecountry;
	}

}