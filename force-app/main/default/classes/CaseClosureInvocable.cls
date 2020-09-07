/*
 * Created by: Mathew
 * Description : Apex class with the invocable method which enqueues a job which makes 
 * an API callout to the workforce planning API on case closure and also intialises the
 * an API_Callout__c record to track the HttpRequest & HttpResponse.
 * This invocable method is re-used for retries on the API callout failure.             
 */

public with sharing class CaseClosureInvocable {

    @InvocableMethod(label='Update Workforce Planning' 
                    description='Queue a job which makes an API call to the workforce planning API to notify the case closure.'
                    category= 'Case')
    public static void  notifyWorkforcePlanning(List<FlowInput> inputs) {

        List<API_Callout__c> apiCalloutsScheduled = new List<API_Callout__c>();
        Map<String, String> fieldMap = new Map<String, String>();
        //get API details and field mapping from custom metadata
        API_Detail__mdt workforcePlanningAPIDetail= new APIDetailMDTSelector().getWorkforcePlanningAPIDetailWithFieldMap();
        if(workforcePlanningAPIDetail != null){
            if(!workforcePlanningAPIDetail.API_Field_Mappings__r.IsEmpty()){
                for(API_Field_Mapping__mdt fm : workforcePlanningAPIDetail.API_Field_Mappings__r){
                    fieldMap.put(fm.SF_Field_Name__c, fm.Target_Field_Name__c); 
                }                
            }
        }
        //field Map for workforce planning API found
        if(!fieldMap.isEmpty()){
            for(FlowInput i : inputs){
                ID jobID = System.enqueueJob(new CaseClosureQueueable(i.kase, fieldMap));
                apiCalloutsScheduled.add(new API_Callout__c(Job_ID__c = jobID, 
                                                     Case__c = i.Kase.Id,
                                                     Status__c = 'QUEUED',
                                                     API_Name__c = workforcePlanningAPIDetail.DeveloperName,
                                                     Attempt_Type__c = i.attemptType));
            }            
        }         
        if(apiCalloutsScheduled.size()>0){
            insert apiCalloutsScheduled;
        }        

    } 
    /*
        Apex type used as type of the input param to the invocable method
    */
   public class FlowInput{
        @InvocableVariable
        public Case kase;
        @InvocableVariable
        public String attemptType;
    }       

}
