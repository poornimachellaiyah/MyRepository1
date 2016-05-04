public with sharing class Utility {

	public static boolean IsProduction() {
	   return (UserInfo.getOrganizationId() == '00DD0000000o0JM');
	}
	
    public static string getProfileIdfromName(string profilename){
        Profile[] theprofile = [select Id, Name from Profile WHERE Name=:profilename LIMIT 1];
        if (theprofile.size()>0) return theprofile[0].Id;
        return null;
    }

    public static string getRecordTypeId(string rtname){
    	RecordType[] thert = [select Id, DeveloperName from RecordType WHERE DeveloperName=:rtname LIMIT 1];
    	if (thert.size()>0) return thert[0].Id;
    	return null;
    }
    
    public static string getProfileName(Id id){
    	Profile[] theprofile = [SELECT Name from Profile WHERE Id=:id LIMIT 1];
    	if(theprofile.size()>0) return theprofile[0].Name;
        return null;
    }
    
    public static Id getUserfromContact(Id id){
    	User[] user = [SELECT Id from User WHERE ContactId=:id LIMIT 1];
    	if(user.size()>0) return user[0].Id;
    	return null;
    }

     public static integer getRandomInteger(){
        integer multiplier = (Math.round(Math.random()) == 1)?10 : 100;
        return Math.round(Math.random() * multiplier);
    }
    
    public static string getRandomString(integer len){
        string s = '';
        string alphabet = 'abcdefghijklmnopqrstuvwxyz';
        for(Integer i = 0; i < len; i++){
            integer randomint = Utility.getRandomInteger();
            if(!(randomint + 1 > alphabet.Length())) s = s + alphabet.substring(randomint, randomint + 1);
            else i--;
        }
        return s;
    }    
    
}