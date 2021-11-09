trigger InsertSelfServiceRequest_Trigger on Self_Service_Request__c (after insert) {
    //  send to Queable to execute the notification sending
    System.enqueueJob(new selfServiceRequestUtils(Trigger.new));
}