
/*
 * Created by: Mathew
 * Description : Queuable class which executes a queuable job on case closure.
 *              
 */
public class CaseClosureQueueable implements Queueable, Database.AllowsCallouts {
    
    
    /*
     * Variable to hold the record passed from the invocable function.
	 */
    private Case ticket{get;Set;}
    /*
     * Variable to hold the field Mapping (Workforce Planning API) passed from the invocable function.
	 */
    private Map<String, String> fieldMap{get;Set;}
    
    /*
     * Constructor
     * Used to set the values for the case and field Mapping to be used to generate the API request body.
     */
    public CaseClosureQueueable(Case ticket, Map<String, String> fieldMap){
        this.ticket = ticket;
        this.fieldMap = fieldMap;
    }
    
    /*
     * Queueable interface method
     * This method frames the API callout request body and captures the information regarding the API callout
     * API callouts response's status, status code, response body etc are captured.
     */
    public void execute(QueueableContext context) {

        //Generates the request body leveraging the custom metadata.
        String reqBody = createAPIRequestBodyFromCase(this.ticket, fieldMap);
        //SOQL to retrieve the API_Callout__c record which was queued as part of the invocable function.
        API_Callout__c currentAPICallout = new APICalloutSelector().getAPICalloutByJobId(context.getJobId())[0];
                
        //To capture duration of the callout
        Long start = System.now().getTime();
        try{
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:Workforce_Planning_API/');
            System.debug('request body'+reqBody);
            request.setBody(reqBody);
            HttpResponse response = h.send(request);
            String responseBody = response.getBody();
            currentAPICallout.Status_Code__c = String.valueOf(response.getStatusCode());
            if(response.getStatusCode() == 200){
                currentAPICallout.status__c = 'OK';
                //deserialize the JSON response to retrieve the secret key
                APIResponseBody apiRes = (APIResponseBody) JSON.deserialize(responseBody, APIResponseBody.class);
                if(apiRes.success){
                    Case caseToUpdate = new Case (Id = ticket.Id, Secret_Key__c = apiRes.secretKey);
                    update caseToUpdate;
                }
            }else{
                currentAPICallout.status__c = 'KO';
            }
            currentAPICallout.Response_Body__c = responseBody;
        }catch(Exception e){
            currentAPICallout.status__c = 'Failed';
            currentAPICallout.Response_Body__c = e.getStackTraceString().replace('\n',' / ')+' - '+e.getMessage();

            //Retry logic on callout failure can be implmented here.
            //However retry is handled via process builder as part of this solution.            
            /*ID jobID = System.enqueueJob(new CaseQueuebleJob(this.ticket));
            API_Callout__c retry = new API_Callout__c(Job_ID__c = jobID, 
                                                Case__c = this.ticket.Id,
                                                Status__c = 'QUEUED',
                                                Attempt_Type__c = 'Retry');
            insert retry;*/
			
        }
        //Captures more info regarding the callout
        currentAPICallout.Timestamp__c = System.now();
        currentAPICallout.Duration__c = system.now().getTime()-start;
        update currentAPICallout;
        
    }
    
    /* Method which generates the callout body leveraging the field mapping.
     * This can be potentially enhanced to a utility method which can be used to generate API request body
     * for different objects leveraging field mapping custom metadata.
	 */
    private string createAPIRequestBodyFromCase(Case ticket, Map<String,String> fieldMap){
        String calloutBody = '';
        Map<String, Schema.SObjectField> fields = Case.getSobjectType().getDescribe().fields.getMap();
        for(String key : fields.keyset()){
            if(fieldMap.containsKey(key)){
                calloutBody += EncodingUtil.urlEncode(fieldMap.get(key), 'UTF-8') + '=' + EncodingUtil.urlEncode((String)ticket.get(key), 'UTF-8') + '&';                                
            }                                   
        }
        return calloutBody.removeEnd('&');   
    }

    /*
    * Apex type (wrapper) which is used to deserialize the JSON response.
	*/
    public class APIResponseBody{
        public boolean success;
        public string error;
        public string secretKey;
    }    
}
