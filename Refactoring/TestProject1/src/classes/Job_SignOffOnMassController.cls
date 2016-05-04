/**
Created by: Sunil kumar
Version: 1.0 intial release
purpose : Job Mass SignOff functionalit UR-000047 use case
 */
public class Job_SignOffOnMassController{

    ApexPages.StandardSetController setCon;
    public boolean IsRecordSelected{get;set;}
    public boolean IsRecordAlreadySignOff{get;set;}
    public List<Job__c> AlreadySignOffJobs{get;set;}
    public List<Job__c> SelectedJobs{get;set;}
    public String retUrl{get;set;}
    public Job_SignOffOnMassController(ApexPages.StandardSetController controller) {
        retUrl=Apexpages.currentpage().getparameters().get('retUrl');
        system.debug('***********retUrl:'+retUrl);
        setCon = controller;
        IsRecordAlreadySignOff=false;
        
        system.debug('***********setCon:'+setCon.getSelected());
       
            AlreadySignOffJobs=new List<Job__c> ();
            SelectedJobs=new List<Job__c> ();
            if(setCon.getSelected().size()>0){
                system.debug('********setCon.getSelected():'+setCon.getSelected());
                Set<Id> JobIds=new Set<Id>();
                List<Job__c> jobs=new List<Job__c>();
                jobs=setCon.getSelected();
                for(Job__c jb:jobs){
                    JobIds.add(jb.id);
                }
                for(Job__c job:[select id,Name,Demand_Sign_Off_Date__c from Job__c where id IN:JobIds]){
                    SelectedJobs.add(job);
                }
                IsRecordSelected=true;
            }else{
                IsRecordSelected=false;
            }
                
    }
   
    public PageReference signoffrecords(){
        
            List<Job__c> UpdateJoblist=new List<Job__c>();
            if(SelectedJobs.size()>0){
                for(Job__c ja:SelectedJobs){
                    if(ja.Demand_Sign_Off_Date__c==null){
                        ja.Demand_Sign_Off_Date__c=system.today();
                        UpdateJoblist.add(ja);
                    }else{
                        AlreadySignOffJobs.add(ja);
                        IsRecordAlreadySignOff=true;
                    }
                }
                if(UpdateJoblist.size()>0){
                    update UpdateJoblist;
                }
            }    
            if(AlreadySignOffJobs.size()==0 && UpdateJoblist.size()>0){
                PageReference p2=new PageReference(retUrl);
                p2.setredirect(true);
                return p2;
            
            }
        
            system.debug('*******IsRecordAlreadySignOff:'+IsRecordAlreadySignOff);
            return null;
    }
    public Pagereference UpdateAlreadySignOffRecords(){
        for(Job__c ja:AlreadySignOffJobs){
            ja.Demand_Sign_Off_Date__c=system.today();
        }
        update AlreadySignOffJobs;
        PageReference p2=new PageReference(retUrl);
        p2.setredirect(true);
        return p2;
    }
    
    public PageReference BackToListView(){
        PageReference p2=new PageReference(retUrl);
        p2.setredirect(true);
        return p2;
    }
    
}