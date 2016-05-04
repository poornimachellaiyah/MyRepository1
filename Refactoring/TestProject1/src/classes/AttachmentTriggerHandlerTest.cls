/*Dinesh-TPT-RecruitV2 changes-06/June/2015
 Test class created for the AttachementTriggerHandler.*/
 
@isTest
private class AttachmentTriggerHandlerTest{

    static testMethod void testAttachments()
    {
        job__c j=new Job__c();
        insert j;
 
        Attachment attach=new Attachment();     
        attach.Name='VSOJD';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=j.id;
        insert attach;
        
        Attachment attach1=new Attachment();     
        attach1.Name='TestFile';
        Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
        attach1.body=bodyBlob1;
        attach1.parentId=j.id;
        insert attach1;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:j.id];        
    }
}