/*
 * Created by: Mathew
 * Description : Selector class which host the SOQL methods for the custom metadata API_Detail__mdt.
 *              
 */

public with sharing class APIDetailMDTSelector {

    public  API_Detail__mdt getWorkforcePlanningAPIDetailWithFieldMap() {
        return [SELECT DeveloperName,
                SF_Object_Name__c,
                (SELECT Id,SF_Field_Name__c,Target_Field_Name__c
                FROM API_Field_Mappings__r)
                FROM API_Detail__mdt 
                WHERE DeveloperName = 'Workforce_Planning'
                LIMIT 1];         
    }   
}
