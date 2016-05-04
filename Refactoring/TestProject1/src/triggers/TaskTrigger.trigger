/*Dinesh-TPT-Recruit Phase-2 changes-06/July/2015
 class created to get the information about the Task in 'Activity History' section.*/
 
trigger TaskTrigger on Task (after insert) {
    TaskTriggerHandler.getHandler().execute();
}