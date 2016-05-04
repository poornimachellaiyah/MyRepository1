global class ScheduledPMLTDeletedForm implements Schedulable {
  
  global void execute(SchedulableContext sc) {
  
    PMLTDeltedFormController pc=new PMLTDeltedFormController();    
    Database.executeBatch(pc,5);   
 
  }

}