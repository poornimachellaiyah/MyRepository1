global class ScheduledFairsailSalaryDataLoading implements Schedulable {
  
  global void execute(SchedulableContext sc) {
  
    FairsailSalaryDataLoadingController  dataLoading=new FairsailSalaryDataLoadingController ();    
    Database.executeBatch(dataLoading,10);    
 
  }

}