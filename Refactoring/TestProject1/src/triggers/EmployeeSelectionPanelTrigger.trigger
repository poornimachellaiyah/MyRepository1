trigger EmployeeSelectionPanelTrigger on Employee_Selection_Panel__c (
	before insert, before update, before delete,
	after insert, after update, after delete, after undelete   
) {
	EmployeeSelectionPanelTriggerHandler.getHandler().execute();
}