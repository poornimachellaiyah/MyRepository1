global class ScheduledPMLTForm implements Schedulable {
  
  global void execute(SchedulableContext sc) {
     
    PMLTFormDataController pc=new PMLTFormDataController();    
    Database.executeBatch(pc,5);   
  }

}