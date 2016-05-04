global class ScheduledFetchSharepointMetaInfo implements Schedulable {
  
  global void execute(SchedulableContext sc) {
    SharepointMetadataController smc=new SharepointMetadataController();
    smc.doFetchSharepointMetaInfo();
    
  }

}