/*
 * Created by: Mathew
 * Description : Test class for CaseClosureInvocable            
 */

@IsTest
public with sharing class CaseClosureInvocableTest {


    @testSetup static void setupData() {
        // Ideally test data creation as part of the @testSetup can be handled using the TestDataFactory pattern.
        // Skipping the TestDataFactory pattern as complex orgs tends to have an TestDataFacory class in place and 
        // deploying this code package might overwrite the existing code.
        Case c = new Case (Status = 'New', Subject = 'Test Case', Origin='Phone');
        insert c;
    }

    @IsTest
    static void notifyWorkforcePlanningNewFailAttempt(){
        Test.setMock(HttpCalloutMock.class, new SubmitMockCallout(CONSTANTS.FAIL_MOCK_RESPONSE));
        Case kas = [Select id, ownerId from case where Subject = 'Test Case' limit 1];
        Test.startTest();
            kas.status = 'Closed';
            update kas;
        Test.stopTest();
        API_Callout__c a = [SELECT Job_Id__c, Status__c, Attempt_Type__c, Case__r.Secret_Key__c 
                            FROM API_Callout__c 
                            WHERE API_Name__c =: CONSTANTS.WP_API_NAME limit 1];
        System.assert(a!=NULL);
        System.assertEquals(a.Status__c,'KO');
        System.assertEquals(a.Attempt_Type__c,'New');
        System.assertEquals(a.Case__r.Secret_Key__c,null);

    }    

    @IsTest
    static void notifyWorkforcePlanningNewSuccessAttempt(){
        Test.setMock(HttpCalloutMock.class, new SubmitMockCallout(CONSTANTS.SUCCESS_MOCK_RESPONSE));
        Case kas = [Select id, ownerId from case where Subject = 'Test Case' limit 1];
        Test.startTest();
            kas.status = 'Closed';
            update kas;
        Test.stopTest();
        API_Callout__c a = [SELECT Job_Id__c, Status__c, Attempt_Type__c, Case__r.Secret_Key__c 
                            FROM API_Callout__c 
                            WHERE API_Name__c =: CONSTANTS.WP_API_NAME limit 1];
        System.assert(a!=NULL);
        System.assertEquals(a.Status__c,'OK');
        System.assertEquals(a.Attempt_Type__c,'New');
        System.assertEquals(a.Case__r.Secret_Key__c,'secret');
    }    

    @IsTest
    static void notifyWorkforcePlanningRetryAttempt(){
        Test.setMock(HttpCalloutMock.class, new SubmitMockCallout(CONSTANTS.FAIL_MOCK_RESPONSE));
        Case kas = [Select id, ownerId from case where Subject = 'Test Case' limit 1];
        Test.startTest();
            kas.status = 'Closed';
            update kas;
        Test.stopTest();
        List<API_Callout__c> calloutList = new List<API_Callout__c>([SELECT Job_Id__c, Status__c, Attempt_Type__c, Case__r.Secret_Key__c 
                                                                    FROM API_Callout__c 
                                                                    WHERE API_Name__c = : CONSTANTS.WP_API_NAME 
                                                                    AND Case__c =: kas.Id]);
        System.assert(calloutList!=NULL);
        System.assertEquals(calloutList.size(),2);

    }    

}
