public class PostJobsToRandstadController{
  public Job__c job{get;set;}
  public String resultMsg{get;set;}
  public String errormsg{get;set;}
  public Blob csvFileBody{get;set;}
  public string csvAsString{get;set;}
  public String[] csvFileLines{get;set;}
  
  Map<String,String> countryMap=new Map<String,String>();   

  public PostJobsToRandstadController()
  {    
    //createXmlForJobRecord();      
  }
  
  //Method to invoke Randstad webservice
  public void postJobsToWebservice()
  {
     String retVal;
     try
     { 
         //TPT: Dinesh - Randstad Integration changes - 12/July/2015
        //Fetch the job records and store it in list variable jobRecords
        List<Job__c> jobRecords=[SELECT id,Job_Id__c,Type__c,Help_Job_Ad_Url__c,country__r.name,Application_Closing_Date__c,
                  External_Advert_Start_Date__c,External_Advert_End_Date__c,Pay_Band_Annual_Salary_Minimum__c,
                  Pay_Band_Annual_Salary_Maximum__c,Projected_Duration_Weeks__c,Job_Title__c,How_To_Apply__c,
                  Primary_Work_Town_City__c,Role_Overview__c,Introduction_to_VSO__c,Additional_Advert_Text__c,
                  Ideal_Applicant_Summary__c,Randstad_Type_Id__c,Primary_Skill__r.Randstad_Sector_ID__c,Randstad_Currency_Id__c FROM job__c WHERE Help_Share_Externally__c=:true AND
                  Job_Status__c=:'Approved for Recruitment'];
        
        
        List<StaticResource> sr =[SELECT body, name FROM StaticResource WHERE Name=:'RandstadCountryList'];
        
        //TPT: Dinesh - Randstad Integration changes - 12/July/2015
        //Logic to get the country data from excel and load in to countrymap object 
        //Convert the data from blob type to string                                  
        csvAsString = sr[0].body.toString();
        //Split the records 
        csvFileLines = csvAsString.split('\n'); 
        for(Integer i=1;i<csvFileLines.size();i++)
        {
            string[] csvRecordData = csvFileLines[i].split(',');
            string countryId=csvRecordData[0];               
            string countryValue=csvRecordData[1].trim();               
            countryMap.put(countryValue,countryId);
        }                          
       
       //TPT: Dinesh - Randstad Integration changes - 12/July/2015                           
       //webservice should not be invoked while runing the test class. 
       //Invoke the Randstad webservice     
      
       if(!Test.isRunningTest())
       {           
           RandstadJobpostingWebservice.Dova_x0020_Web_x0020_ServiceSoap obj=new RandstadJobpostingWebservice.Dova_x0020_Web_x0020_ServiceSoap();       
           retVal = String.valueOf(obj.ImportJobs(createXmlForJobRecord(jobRecords)));
           System.Debug('RANDSTAD RESULTS'+retVal);
           //to display the message in page
           resultMsg =retVal;
       }
       //TPT: Dinesh - Randstad Integration changes - 12/July/2015
       //Inovke the method while runing the test class.
       if(Test.isRunningTest())
       {         
           retVal=createXmlForJobRecord(jobRecords);
           //to display the message in page
           resultMsg =retVal;
       }
     }
     catch (Exception e)
     {
       errormsg=e.getStackTraceString();
       System.debug('************errormsg:'+errormsg);       
     }           
  }
  
  //Method to return the country id 
  public string getCountryId(string countryName)
  {
      string countryId;                   
      if(countryMap.ContainsKey(countryName))
      {
          countryId=countryMap.get(countryName);   
      }
      return countryId;
  }
  
   //Method to build the xml structure for jobs
   public String createXmlForJobRecord(List<Job__c> lstJob)
   {
      
       //To build the xml structure
       XmlStreamWriter w = new XmlStreamWriter();
       w.writeStartDocument('utf-8', '1.0');
       w.writeStartElement(null, 'Envelope ',null);
       w.writeNamespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance');
       w.writeNamespace('xsd', 'http://www.w3.org/2001/XMLSchema');
       w.writeNamespace('','http://webservice.dova.org/dova/jobs/v1');

       w.writeStartElement(null, 'Header', null);
       w.writeStartElement(null, 'Username', null);
       w.writeCharacters('vsojobs');
       w.writeEndElement();//end username 
       w.writeStartElement(null, 'Password', null);
       w.writeCharacters('v$0j0bs!');
       w.writeEndElement();//end password 
       w.writeEndElement();//end header 
       
       w.writeStartElement(null, 'MetaData', null);
       w.writeEmptyElement(null, 'Incremental', null);
       w.writeAttribute(null, null, 'enabled', 'true');
       w.writeEndElement();//end MetaData
       
       w.writeStartElement(null, 'Jobs', null);
       
       string jobid,jobTitle,jobDesc,jobCity,randstadType,randstadSector,randstadCurrencyId;
       string jobSkills,duration,salaryMin,salaryMax;
       string DateCreated,DateExpire,DateEnd,CountryId;
       string jobUrl,RoleOverview,vsoIntro,additionalAdvt;
       
       try 
       {      
           for(Job__c jobRecords:lstJob)           
           {         
              if(jobRecords.Job_Id__c!=null)
              {
                jobid=jobRecords.Job_Id__c;
                jobTitle=jobRecords.Type__c+' -'+jobRecords.Job_Title__c;
                jobDesc=(jobRecords.How_To_Apply__c).escapeHtml4();  
                //TPT: Dinesh - Randstad Integration changes - 12/July/2015
                //string urlVal=jobRecords.Help_Job_Ad_Url__c;
                //string urlValreplace=urlVal.replace('Job_DetailsPage','job_applicationpage');
                jobUrl=jobRecords.Help_Job_Ad_Url__c;                      
                duration=String.valueOf(jobRecords.Projected_Duration_Weeks__c);
                salaryMin=String.valueOf(jobRecords.Pay_Band_Annual_Salary_Minimum__c);
                salaryMax=String.valueOf(jobRecords.Pay_Band_Annual_Salary_Maximum__c);
                jobCity=jobRecords.Primary_Work_Town_City__c;
                CountryId=getCountryId(jobRecords.country__r.name);
    
                //Convert DateTime to Date
                DateTime dt1=jobRecords.External_Advert_Start_Date__c;
                Date externalAdvertStartDate=date.newinstance(dt1.year(), dt1.month(), dt1.day());            
                DateTime dt2=jobRecords.External_Advert_End_Date__c;
                Date externalAdvertEndDate=date.newinstance(dt2.year(), dt2.month(), dt2.day());            
            
                DateCreated=String.valueOf(externalAdvertStartDate);
                DateExpire=String.valueOf(externalAdvertEndDate);
                DateEnd=String.valueOf(jobRecords.Application_Closing_Date__c);
                
                if(jobRecords.Role_Overview__c!=null)
                    RoleOverview=(jobRecords.Role_Overview__c).escapeHtml4();
                if(jobRecords.Introduction_to_VSO__c!=null)
                    vsoIntro=(jobRecords.Introduction_to_VSO__c).escapeHtml4();
                if(jobRecords.Additional_Advert_Text__c!=null)
                    additionalAdvt=(jobRecords.Additional_Advert_Text__c).escapeHtml4();
                if(jobRecords.Ideal_Applicant_Summary__c!=null)
                    jobSkills=(jobRecords.Ideal_Applicant_Summary__c ).escapeHtml4();
                if(jobRecords.Randstad_Type_Id__c !=null)
                   randstadType= string.valueof(jobRecords.Randstad_Type_Id__c); 
                //TPT: Dinesh - Randstad Integration changes - 12/July/2015
                if(jobRecords.Primary_Skill__r.Randstad_Sector_ID__c!=null)   
                {
                    randstadSector=String.valueOf(jobRecords.Primary_Skill__r.Randstad_Sector_ID__c);
                }
                
                //TPT: Dinesh - Randstad Integration changes - 12/July/2015
                if(jobRecords.Randstad_Currency_Id__c!=0)
                {
                    randstadCurrencyId=string.valueof(jobRecords.Randstad_Currency_Id__c);
                }
               
                w.writeStartElement(null, 'Job', null);
                w.writeStartElement(null, 'JobId', null);
                w.writeCharacters(jobid);
                w.writeEndElement();//end JobId
            
                w.writeStartElement(null, 'JobInformation', null);
                w.writeStartElement(null, 'Title', null);
                w.writeCharacters(jobTitle);
                w.writeEndElement();//end Title
                
                w.writeStartElement(null, 'Description', null);
                w.writeCData('<p>'+RoleOverview+'</p>');
                w.writeCData('<b>About VSO</b>');
                w.writeCData('<p>'+vsoIntro+'</p>');
                w.writeCData('<p>'+additionalAdvt+'</p>');                      
                w.writeEndElement();//end Description   
                          
                w.writeStartElement(null, 'Skills', null);
                if(jobSkills!=null)
                {
                    w.writeCData('<p>'+jobSkills+'</p>');          
                }
                w.writeEndElement();//end Skills               
                
                if(jobRecords.Primary_Skill__r.Randstad_Sector_ID__c!=null){   
                    w.writeStartElement(null, 'SectorId', null);                          
                    w.writeCharacters(randstadSector);     
                    w.writeEndElement();//end Randstad SectorId
                }
            
                w.writeStartElement(null, 'JobTypeId', null);           
                w.writeCharacters(randstadType); 
                w.writeEndElement();//end Randstad JobTypeId               
            
                if(duration!=null)
                {         
                  w.writeStartElement(null, 'Duration', null);            
                  w.writeCharacters(duration);
                  w.writeEndElement();//end Duration          
                }  
                
                if(jobUrl!=null)
                {         
                  w.writeStartElement(null, 'Url', null); 
                  w.writeCData(jobUrl);                        
                  w.writeEndElement();//end Url
                }  
                w.writeEndElement();//end JobInformation
            
                if((salaryMin!=null) ||(salaryMax!=null))
                {
                    w.writeStartElement(null, 'Salary', null);
                    if(salaryMin!=null)
                    {
                        w.writeStartElement(null, 'SalaryMin', null);            
                        w.writeCharacters(salaryMin);
                        w.writeEndElement();//end SalaryMin
                    }
                    if(salaryMax!=null)
                    {
                        w.writeStartElement(null, 'SalaryMax', null);
                        w.writeCharacters(salaryMax);
                        w.writeEndElement();//end SalaryMax
                    }
                    //TPT: Dinesh - Randstad Integration changes - 12/July/2015
                    if((randstadCurrencyId!=null)&&(jobRecords.Randstad_Currency_Id__c!=0))
                    {
                        w.writeStartElement(null, 'CurrencyId', null);
                        w.writeCharacters(randstadCurrencyId);
                        w.writeEndElement();//end CurrencyId
                    }
                     //TPT: Dinesh - Randstad Integration changes - 12/July/2015
                     w.writeStartElement(null, 'CompensationType', null);
                     w.writeCharacters('5');
                     w.writeEndElement();//end CompensationType
                     
                    w.writeEndElement();//end Salary
                }
            
                if((jobCity!=null)||(CountryId!=null))
                {
                     w.writeStartElement(null, 'JobLocation', null);
                     if(jobCity!=null)
                     {
                          w.writeStartElement(null, 'City', null);            
                          w.writeCharacters(jobCity);            
                          w.writeEndElement();//end City
                     }
                     if(CountryId!=null)
                     {
                          w.writeStartElement(null, 'CountryId', null);            
                          w.writeCharacters(CountryId);            
                          w.writeEndElement();//end CountryId
                     }            
                     w.writeEndElement();//end JobLocation
                }
            
                w.writeStartElement(null, 'JobDates', null);
                if(DateCreated!=null)
                {
                    w.writeStartElement(null, 'DateCreated', null);            
                    w.writeCharacters(DateCreated);
                    w.writeEndElement();//end DateCreated
                }
                if(DateExpire!=null)
                {
                    w.writeStartElement(null, 'DateExpire', null);            
                    w.writeCharacters(DateExpire);
                    w.writeEndElement();//end DateExpire
                }
                if(DateEnd!=null)
                {
                    w.writeStartElement(null, 'DateEnd', null);            
                    w.writeCharacters(DateEnd);
                    w.writeEndElement();//end DateEnd
                }
                w.writeEndElement();//end JobDates
                w.writeEndElement();//end Job
              }  
                               
           }          
       }
       catch (Exception e)
       {
          errormsg=e.getStackTraceString()+'error2'+e.getMessage();
          System.debug('************errormsg:'+errormsg);
       } 
       w.writeEndElement();//end Jobs       
       
       //Mention each jobid in a separate tag to delete the jobs from Dova system
       /*
       w.writeStartElement(null, 'DeleteJobs', null);                         
       w.writeEmptyElement(null, 'Delete', null);
       w.writeAttribute(null, null, 'jobid', 'JOB0071854');   
       w.writeEmptyElement(null, 'Delete', null);
       w.writeAttribute(null, null, 'jobid', 'JOB0071855');     
       w.writeEndElement();//end DeleteJobs
       */
       
       w.writeEndDocument();
       String xmlOutput = w.getXmlString();
       resultMsg=xmlOutput;
       //System.debug(resultMsg);
       w.close();              
       return xmlOutput;
   }

}