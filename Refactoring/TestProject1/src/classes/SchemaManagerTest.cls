@isTest
private class SchemaManagerTest {

	static testMethod void testgetSchemaMap(){
		Map<String, Schema.SObjectType> sobjectSchemaMap = SchemaManager.getSchemaMap();
	}

	static testMethod void testgetSObjectSchema(){
		Schema.SObjectType thesobjecttype = SchemaManager.getObjectSchema('Account');
	}

}