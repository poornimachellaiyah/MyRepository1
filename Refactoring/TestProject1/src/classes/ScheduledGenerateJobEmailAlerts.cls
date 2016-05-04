global class ScheduledGenerateJobEmailAlerts implements Schedulable {
  
  global void execute(SchedulableContext sc) {
    JobEmailAlertsController jac=new JobEmailAlertsController();
    jac.doJobAlertDetails();
  }

}