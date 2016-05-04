public class RecordSharingUtilityClass {

    public static List<sobject> CreateShareRecord(List<Id> recordIds, Id userOrGroupId,String objName, String recordAccess){
      	Schema.SObjectType objToken = SchemaManager.getObjectSchema(objName);
		system.debug('*****objToken;'+objToken);
		List<sobject> recShrs  = new List<sobject>();
		
		sobject rShare;
		for(Id rid:recordIds){
			rShare= objToken.newSObject();
			// Set the ID of record being shared.
			rShare.put('ParentId',rid);
      		// Set the ID of user or group being granted access.
			rShare.put('UserOrGroupId',userOrGroupId);
     	 	// Set the access level.
			rShare.put('AccessLevel',recordAccess);
     		// Set rowCause for sharing.
      		//Sharing reason will be provided in trigger as it will vary based on custom object
			//Add it to list 
			recShrs.add(rShare)	;
		}
		return recShrs;
	}
	
	public static SObject CreateShareRecordSingle(Id recordId, Id userOrGroupId, String objectName, string recordAccess, string sharereason){
		Schema.SObjectType objToken = SchemaManager.getObjectSchema(objectName);
		SObject rShare;
		rShare=objToken.newSObject();
		rShare.put('ParentId',recordId);
		rShare.put('UserOrGroupId',userOrGroupId);
		rShare.put('AccessLevel',recordAccess);
		rShare.put('RowCause', sharereason);
		return rShare;
	}
	
}