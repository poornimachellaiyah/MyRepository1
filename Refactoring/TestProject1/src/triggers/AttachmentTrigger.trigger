/*Dinesh-TPT-RecruitV2 changes-06/June/2015
 class created to invoke the AttachmentTriggerHandler when a document is attached.*/
 
trigger AttachmentTrigger on Attachment (after insert) {
AttachmentTriggerHandler.getHandler().execute();
}