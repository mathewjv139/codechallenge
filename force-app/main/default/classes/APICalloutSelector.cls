/*
 * Created by: Mathew
 * Description : Selector class which host the SOQL methods for the custom object API_Callout__c.
 *              
 */

public with sharing class APICalloutSelector {

    public  List<API_Callout__c> getAPICalloutByJobId(String jobId) {
        return [SELECT Id,Duration__c,Job_Id__c,
                Response_Body__c,Status_Code__c,
                Status__c,Timestamp__c
                FROM API_Callout__c 
                WHERE Job_Id__c = :jobId
                LIMIT 1];         
    }      
}
