/*--------------------------------------------------------------------------------------
   Title:Job Search Controller Class
   Version:1.0
   Author: Sunil Kumar
   Created date: 06th June 2013
   Purpose: To handle the business logic of Searching Job Page.
   
   Modified date:30th July, 2013
   Modified by:Sunil Kumar
   Version: 1.1
   Purpose: to add consultant job type for search 
   
   Modified date:11 Dec 2015,
   Modified by: Narpavi-TPT
   Purpose: To display the E-Volunteer jobs in the job board.
   Search Tag: TPT-(11-Dec-2105) 
----------------------------------------------------------------------------------------- */  
 
public class Job_ListPageController{ 
     
    public list<Job__c> lstFilteredJobs{get;set;}
    public String searchText {get;set;}
    public job__c ObjJob {get;set;}
  
    public string soqlquery {get;set;}
    public string condition {get;set;}
    public string SearchBoxText {get;set;}
    
    /*-------------------variables for pagination start-------------------------*/
    public Integer pageSize {get;set;}
    public Integer currentPage {get;set;}
    public String currentPageInfo{get;set;}
    
    // for disabling pagination links
    public Boolean showPrevious {get;set;} 
    public Boolean showNext {get;set;}
    
    private Integer totalRecords;
    private Integer pageNumber;
    
    private String mProfileName;
    private String mMode;
  
    /*------------------- variables for Sorting Columns-------------------------*/
    public String sortDir{get;set;}
    public String sortBy{get;set;}
    
    
    /*-----------Variables to store filter values-----------------*/
    public String selectedCountries{get;set;}
    public String selectedJobType{get;set;}
    public String selectedSkills{get;set;}
    public String selectedStartDate{get;set;}  
    public List<String> JobStartDates{get;set;}      
    /*------------------------------------------------------------*/

    public boolean getShowHeaderandSidebar(){
      //return (Utility.getProfileName(Userinfo.getProfileId())!='Job Opportunities Sites Profile');
      return (mProfileName != 'Job Opportunities Sites Profile');
    }
    
    /*------------------------------Getters and Setters -----------------------*/  
    
    public List<SelectOption> getCountries(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectoption('','--All--'));
        //String qryString='select id,Name from Country__c';
        String qryString='select id,Name from Country__c ';
        qryString += 'where (VSO_Office__c = \'Country office\' OR VSO_Office__c = \'Federation office\'  OR VSO_Office__c = \'Country & federation office\') ';
        if(strSelectedRegion!='' && strSelectedRegion!=null){
          qryString+=' and Region__c=\''+strSelectedRegion+'\'';
        }
       // qryString+=' ORDER BY Name LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())';
         qryString+=' ORDER BY Name ';
         system.debug('************qryString'+qryString);
        list<Country__c> countryNames = new list<Country__c>(); 
        countryNames =Database.query(qryString);
        if(countryNames.size()>0){
          for(Country__c  cntry: countryNames){
              options.add(new SelectOption(cntry.Id,cntry.Name));
          }  
        }
         return options;
    }
    
     public List<SelectOption> getRecordType(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectoption('','--All--'));
        //options.add(new selectOption('--Select All Types--', '--Select All Types--')); 
        Schema.DescribeSObjectResult R = Job__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
         for (Schema.RecordTypeInfo gg : RT){
            if(gg.getName()!='Master')
             options.add(new SelectOption(gg.getRecordTypeId(),gg.getName()));
        }
       return options;
    }
    

     public List<SelectOption> getSkillNames(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectoption('','--All--'));
        // options.add(new selectOption('SelectAll', '--Select All Skills--')); 
       
         list<Skill__c> Skills = new list<Skill__c>();   
        Skills =[ Select s.Name, s.Id, s.Active__c From Skill__c s WHERE s.Active__c = TRUE ORDER BY s.Name LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())];
        
        for(Skill__c  sk: Skills){
            options.add(new SelectOption(sk.Id, sk.Name));
        }
       return options;
    }
    
    public List<SelectOption> getStartDatesOfJobs(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectoption('','--All--'));
        if(JobStartDates.size()>0){
            for(String ss:JobStartDates){
                options.add(new SelectOption(ss,ss));
            }
        }
        return options;
    }
    public String strSelectedRegion{get;set;}
    public List<SelectOption> getAllRegions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectoption('','--All--'));
        Schema.DescribeFieldResult fieldResult =Country__c.Region__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    public String strSkillGroup{get;set;}
    public List<SelectOption> getAllSkillGroup(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectoption('','--All--'));
        Schema.DescribeFieldResult fieldResult =Skill__c.Group__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple){
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    /*---------------------------------------------------------------------------------------*/
    
    
    
    
    
    
    
    public Job_ListPageController() {
      
      if (ApexPages.currentPage().getParameters().get('m') != null)
      {
        mMode = ApexPages.currentPage().getParameters().get('m');
      }
      
      strSelectedRegion='';
        ObjJob = new job__c();
        JobStartDates=new List<String>();
      mProfileName = Utility.getProfileName(Userinfo.getProfileId());
        searchJobs();
        if(lstFilteredJobs.size()>0){
            FindJobsStartDateValue(lstFilteredJobs);
        }
    } 
    
    
    /*------------------Job Search Functionality starts------------------------------------------------------------------------*/
    public String EVolJobs='E-placement';  //TPT-(11-Dec-2105) 
    public String Voljobs='Volunteer';     //TPT-(11-Dec-2105) 
    private String WhereClassGenerator(){
        String WhereClause='';
   
        if((selectedCountries==null || selectedCountries=='') && (selectedJobType==null || selectedJobType=='') && (strSkillGroup==null || strSkillGroup=='') && (strSelectedRegion==null || strSelectedRegion==''   )){
                
        }else{
            if(selectedCountries!=null && selectedCountries!=''){
                WhereClause+=' Country__c=:selectedCountries AND';
            }if(selectedJobType!=null && selectedJobType!='' && selectedJobType !='E-Volunteer'){     //TPT-(11-Dec-2105)-Modifed to dispaly voluteer jobs without Volunteer type  as 'E-placement'
                WhereClause+=' Help_Type__c=:selectedJobType AND';
                WhereClause+=' Volunteer_Type__c !=:EVolJobs AND';                  
             }if(selectedJobType =='E-Volunteer'){                                                    //TPT-(11-Dec-2105)-Added to get volunteer job with the Volunteer type as 'E-placement'
                 WhereClause+=' Help_Type__c=:Voljobs AND';                                            
                WhereClause+=' Volunteer_Type__c=:EVolJobs AND';  
              }if(strSelectedRegion!=null && strSelectedRegion!=''){
                WhereClause+=' Region__c=:strSelectedRegion AND'; 
            }
            /*
            if(selectedStartDate!=null && selectedStartDate!=''){
                WhereClause+=' Help_External_Advert_Start_Month_Year__c=:selectedStartDate AND';
            }*/
        }
       
        if(WhereClause.endsWithIgnoreCase('AND')){
            WhereClause=WhereClause.substring(0,WhereClause.length()-4);      
        }
        return WhereClause;
    }  
    public string queryString{get;set;}    
    public void searchJobs(){
        system.debug('******inside searchJobs ');
        //reset search variables
        SearchBoxText='';
        lstFilteredJobs = new list<Job__c>();
        
        boolean SkillFilterRequired=false;
        //where  Help_Share_Externally__c=true
        if((strSkillGroup!=null && strSkillGroup!='')){
            //queryString = 'Select id,Help_Type__c,(select id,Skill__c,Name,Skill__r.Group__c from Job_Skills__r where Skill__r.Group__c=:strSkillGroup),Region__c,Job_Title__c, Application_Closing_Date__c,Type__c,Projected_Start_Date__c ,Help_External_Advert_Start_Month_Year__c ,Desk_Space_Location__c,Help_Share_Externally__c,Projected_Duration_Weeks__c,Country__c,Country__r.name,Actual_Start_Date__c from Job__c where Help_Share_Externally__c=true ';
            //queryString = 'Select id,Help_Type__c,(select id,Skill__c,Name,Skill__r.Group__c from Job_Skills__r where Skill__r.Group__c=:strSkillGroup),Region__c,Job_Title__c, Application_Closing_Date__c,Type__c,Projected_Start_Date__c ,Help_External_Advert_Start_Month_Year__c ,Desk_Space_Location__c,Help_Share_Externally__c,Projected_Duration_Weeks__c,Country__c,Country__r.name,Actual_Start_Date__c from Job__c';
            //Dinesh-TPT-Fix for diplaying job records based on job category
            queryString = 'Select id,Help_Type__c,Volunteer_Type__c,Region__c,Job_Title__c, Application_Closing_Date__c,Type__c,Projected_Start_Date__c ,Help_External_Advert_Start_Month_Year__c ,Desk_Space_Location__c,Help_Share_Externally__c,Projected_Duration_Weeks__c,Country__c,Country__r.name,Actual_Start_Date__c from Job__c where Primary_Skill__r.Group__c=:strSkillGroup';

            queryString += ' and ' + sharejobSOQL();
            SkillFilterRequired=true;
        }else{
            //queryString = 'Select id,Job_Title__c,Help_Type__c,  Application_Closing_Date__c,Type__c,Projected_Start_Date__c ,Help_External_Advert_Start_Month_Year__c ,Desk_Space_Location__c,Help_Share_Externally__c,Projected_Duration_Weeks__c,Country__c,Country__r.name,Actual_Start_Date__c from Job__c where Help_Share_Externally__c=true ' ;
            queryString = 'Select id,Job_Title__c,Help_Type__c,Volunteer_Type__c,Application_Closing_Date__c,Type__c,Projected_Start_Date__c ,Help_External_Advert_Start_Month_Year__c ,Desk_Space_Location__c,Help_Share_Externally__c,Projected_Duration_Weeks__c,Country__c,Country__r.name,Actual_Start_Date__c from Job__c';

            queryString += ' where ' + sharejobSOQL();            
            SkillFilterRequired=false;
        }     
        String Filterquery =WhereClassGenerator();
        if(Filterquery!=null && Filterquery.trim()!=''){
            queryString+=' AND '+Filterquery;   
        }
        //queryString+=' LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())';
        queryString+=' order by Projected_Start_Date__c ';
        
        system.debug('**********queryString:'+queryString);
        lstFilteredJobs = (list<Job__c>)Database.query(queryString);
        
        
        
        system.debug('**********selectedSkills:'+selectedSkills);
        //Dinesh-TPT-Fix for diplaying job records based on job category.
        //The below code commented as the 'Job_Skills' object is not in use currently.
        
        /*if(lstFilteredJobs.size()>0){
            if(SkillFilterRequired==true){
                list<Job__c> temp = new list<Job__c>();
                Set<Id> jobIds=new Set<Id>();
                for(Job__c jb:lstFilteredJobs){
                    if(jb.Job_Skills__r.size()>0){
                        for(Job_Skill__c js:jb.Job_Skills__r){
                            if(js.Skill__r.Group__c==strSkillGroup){
                              temp.add(jb);  
                              break;
                            }
                        }
                    }
                }
                system.debug('**********temp.size():'+temp.size());
                lstFilteredJobs = new list<Job__c>();
                lstFilteredJobs=temp;
                
            }
            system.debug('lstFilteredJobs-------'+lstFilteredJobs.Size());
            //activatePaginationCurrent();
        }*/
       //return null;
    }
     /*------------------Job Search Functionality ends------------------------------------------------------------------------*/
    
    
    private void FindJobsStartDateValue(List<Job__c> lstFilteredJobs){
        Set<String> tempSet=new Set<String>();
        for(Job__c jb:lstFilteredJobs){
            if(jb.Projected_Start_Date__c!=null ){
                if(jb.Help_External_Advert_Start_Month_Year__c!=null && jb.Help_External_Advert_Start_Month_Year__c!=''){
                    if(!tempSet.contains(jb.Help_External_Advert_Start_Month_Year__c)){
                        JobStartDates.add(jb.Help_External_Advert_Start_Month_Year__c);
                        tempSet.add(jb.Help_External_Advert_Start_Month_Year__c);
                    }
                }
            }   
        }
    }
    
    public void SearchFunction(){
        //reset filter variables
        //selectedSkills='';
        selectedJobType='';
        strSelectedRegion='';
        selectedCountries='';
        strSkillGroup='';
        
        
        //selectedSkills='';
        lstFilteredJobs = new list<Job__c>();
        
        system.debug('SearchBoxText----' +SearchBoxText);
        set<Id> skillIdset = new set<Id>();
        
        list<Job__c> SearchOutput = new list<Job__c>();
       
        if (SearchBoxText.trim().length() > 1){
          SearchBoxText=SearchBoxText.trim();
            String searchquery='FIND\''+SearchBoxText+'*\'';

            //searchquery=searchquery+' IN ALL FIELDS RETURNING Job__c (Id,Name,Job_Title__c,Help_Type__c,Region__c,Country__c,Country__r.name,Desk_Space_Location__c,Application_Closing_Date__c,Type__c,Projected_Duration_Weeks__c,Projected_Start_Date__c,Actual_Start_Date__c where Help_Share_Externally__c=true ), Country__c(Id,Name,Region__c), Skill__c(Id,Name,Group__c) ';
            searchquery += ' IN ALL FIELDS RETURNING Job__c (Id,Name,Job_Title__c,Help_Type__c,Volunteer_Type__c,Region__c,Country__c,Country__r.name,Desk_Space_Location__c,Application_Closing_Date__c,Type__c,Projected_Duration_Weeks__c,Projected_Start_Date__c,Actual_Start_Date__c';
       searchquery += ' where ' + sharejobSOQL();
       searchquery += '), Country__c(Id,Name,Region__c), Skill__c(Id,Name,Group__c) ';       
            
            system.debug('****************searchquery:'+searchquery);
            List<List<SObject>>searchList=search.query(searchquery);
            
            List<Job__c> jobs = ((List<Job__c>)searchList[0]);
            List<Country__c> countries = ((List<Country__c>)searchList[1]);
            List<Skill__c> skills = ((List<Skill__c>)searchList[2]);
            system.debug('jobs------'+jobs.size());
            system.debug('countries------'+countries.size());
            system.debug('skills------'+skills.size());
            
            
            if(jobs.size()>0){
                SearchOutput=jobs;
            }
            
            if(countries.size()>0){
                Set<Id> CountryIds=new Set<Id>();
                for(Country__c cn:countries){
                    CountryIds.add(cn.id);
                }
                for(Job__c jb:[Select Id,Job_Title__c,Desk_Space_Location__c,Application_Closing_Date__c,Type__c,Country__c,Country__r.name,Projected_Duration_Weeks__c,Projected_Start_Date__c,Actual_Start_Date__c FROM Job__c Where Country__c IN:CountryIds AND  Help_Share_Externally__c=true]){
                    SearchOutput.add(jb);
                }
            }
            system.debug('SearchOutput------'+SearchOutput.size());
            if(skills.size()>0){
                Set<Id> SkillIds=new Set<Id>();
                for(Skill__c sk:skills){
                    SkillIds.add(sk.id);
                }
                Set<Id> JobIds=new Set<Id>();
                if(SkillIds.size()>0){
                    //need to add filter
                    //for(Job__c jb:[Select Id,(Select Skill__c,Skill__r.Group__c,Job__c From Job_Skills__r WHERE Skill__c IN:SkillIds),Job_Title__c,Desk_Space_Location__c,Application_Closing_Date__c ,Type__c,Country__c,Country__r.name,Projected_Duration_Weeks__c,Projected_Start_Date__c,Actual_Start_Date__c FROM Job__c where Help_Share_Externally__c=true]){
                        //if(jb.Job_Skills__r.size()>0){
                        
                        //Dinesh-TPT-Fix for diplaying job records based on job category
                        for(Job__c jb:[Select Id,Job_Title__c,Desk_Space_Location__c,Application_Closing_Date__c ,Type__c,Country__c,Country__r.name,Projected_Duration_Weeks__c,Projected_Start_Date__c,Actual_Start_Date__c FROM Job__c where Help_Share_Externally__c=true and Primary_Skill__c IN:SkillIds]){
                        if(jb!=null){

                          system.debug('job ids-----'+jb.id);
                            SearchOutput.add(jb);
                        }
                    }
                }
            }
            system.debug('SearchOutput after skill manipulation------'+SearchOutput.size());
            if(SearchOutput.size()>0){
                Set<Id> JobIds=new Set<Id>();
                for(Job__c jb:SearchOutput){
                  
                    if(!JobIds.contains(jb.id)){
                        lstFilteredJobs.add(jb);
                        JobIds.add(jb.id);
                    }
                }
            }
            system.debug('lstFilteredJobs------'+lstFilteredJobs.size());
        }else{
            searchJobs();
        }
    }
    
    
    /*----------------Pagination code starts (Currently not in used 12 June 2013)------------------------------------------------------------*/
    /*
    public void activatePaginationCurrent(){
        currentPage = 0;
        pageSize = 10;
        pageNumber = 1;
        showPrevious = false;
        totalRecords = lstFilteredJobs.size();
        if(totalRecords > pageSize)
                showNext = true;
        else
                showNext = false;
        currentPageInfo = 'Showing Page ' + pageNumber +   ' - ' + (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1) + ' of ' + totalRecords + ' items ' ;
    }
    
    public void showPrevious(){ 
        currentPage = currentPage - pageSize;
        pageNumber--;
        enableDisablePaginationLinks();       
    }
    
    public void showNext(){
        currentPage = currentPage + pageSize;
        pageNumber++;
        enableDisablePaginationLinks();
    }
    
    public void showFirst(){
        currentPage = 0;
        pageNumber = 1;
        enableDisablePaginationLinks();
    }
    
    public void showLast(){
        currentPage = (Math.mod(totalRecords, pageSize) == 0) ? totalRecords - pageSize : (totalRecords / pageSize) * pageSize;
        pageNumber = (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1);
        enableDisablePaginationLinks();
    }
    
    private void enableDisablePaginationLinks(){
        if(currentPage == 0)
            showPrevious = false;
        else
            showPrevious = true;

         if((totalRecords - pageSize) <= currentPage)
               showNext = false;
         else
            showNext = true;
            currentPageInfo = 'Showing Page ' + pageNumber +   ' - ' + (Math.mod(totalRecords, pageSize) == 0 ? totalRecords/pageSize : (totalRecords/pageSize) + 1) + ' of ' + totalRecords + ' items ' ;
    }
 
    /*----------------Pagination code ends------------------------------------------------------------*/
    
    /*-------------------------sorting functionality starts-------------------------------------------------------------*/
    
    public PageReference SortJobRecords(){
        system.debug('************************sortBy'+sortBy);
        system.debug('************************sortDir'+sortDir);
        if(lstFilteredJobs.size()>0){
            lstFilteredJobs=sortFilteredJobs(lstFilteredJobs,sortDir,sortBy);
        }
        return null;
    }
    public List<Job__c> sortFilteredJobs(List<Job__c> lstFilteredJobs,String sortorder,String sortByField){
        List<Job__c> inputList=lstFilteredJobs;
        List<Job__c> outputList=new List<Job__c>();
        
        
        if(inputList.size()>0){
            Map<String,List<Job__c>> sortByFieldToWrappermap=new Map<String,List<Job__c>>();      
            List<String> sortingFieldList=new List<String>();
            
            
            integer recordCounter=0;
            for(Job__c cw:inputList){
                
                Sobject ss=cw;
                String fieldvalue=string.valueof(ss.get(sortByField));
                if(!sortByFieldToWrappermap.containskey(fieldvalue)){
                    sortingFieldList.add(fieldvalue);
                    sortByFieldToWrappermap.put(fieldvalue,new List<Job__c>()); 
                    sortByFieldToWrappermap.get(fieldvalue).add(cw);
                }else{
                    sortByFieldToWrappermap.get(fieldvalue).add(cw);
                }
               
                recordCounter+=1;
            }
            
            if(sortingFieldList.size()>0){
                system.debug('********before sortingFieldList;'+sortingFieldList);
                /*-----below code is not required number field is not present on UI for sorting--------------------------
                if(String.valueof(Schema.getGlobalDescribe().get('Job__c').getDescribe().fields.getMap().get(sortByField).getDescribe().getType()).equalsignorecase('DOUBLE')){
                    List<Decimal> sortingDecimalFieldList=new List<Decimal>();
                    for(String ss:sortingFieldList){
                      
                        sortingDecimalFieldList.add(Decimal.valueof(ss));
                    }
                    sortingDecimalFieldList.sort();
                    sortingFieldList=new List<String>();
                    for(Decimal ss:sortingDecimalFieldList){
                        sortingFieldList.add(String.valueof(ss));
                    }
                }
                */
                sortingFieldList.sort();
                system.debug('********after sortingFieldList;'+sortingFieldList);
                if(sortDir.equalsignorecase('ASC')){
                    for(String ss:sortingFieldList){
                        outputList.addAll(sortByFieldToWrappermap.get(ss));
                    }
                }else{
                    for(integer i=sortingFieldList.size()-1;i>=0;i--){
                        outputList.addAll(sortByFieldToWrappermap.get(sortingFieldList[i]));
                    }
                }
            }
        }
        
        return outputList;
    }
    /*-------------------------sorting functionality ends-------------------------------------------------------------*/

    private string sharejobSOQL()
    {
      String workSOQL = 'Job_Internally_Shared__c = true';
      
      if (mMode != 'i' && mProfileName == 'Job Opportunities Sites Profile')
      {
        workSOQL = 'Help_Share_Externally__c = true';
      }
      return workSOQL;
    }
    
    public string getpageTitle()
    {
      String workPageTitle;
      workPageTitle = 'Job opportunities';
      if (mMode == 'i' ||  mProfileName != 'Job Opportunities Sites Profile')
      {
        workPageTitle = 'Internal job opportunities';
      }
      
      return workPageTitle;
    }
    
}