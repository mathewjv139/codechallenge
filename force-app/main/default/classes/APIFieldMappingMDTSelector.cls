public with sharing class APIFieldMappingMDTSelector {

    public Map<String, String> getWorforcePlanningApiDetails() {
        Map<String, String>fieldMapping = new Map<String, String>();
        for(API_Field_Mapping__mdt fm : [SELECT Id,SF_Field_Name__c,Target_Field_Name__c
                FROM API_Field_Mapping__mdt 
                WHERE API_Detail__r.DeveloperName = 'Workforce_Planning']){
                    fieldMapping.put(fm.SF_Field_Name__c, fm.Target_Field_Name__c);            
            }                                
        return fieldMapping;
    }  

}
