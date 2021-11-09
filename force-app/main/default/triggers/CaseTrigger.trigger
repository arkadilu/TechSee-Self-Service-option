trigger CaseTrigger on Case (after insert) {

    Id typeId = [SELECT Id FROM CustomNotificationType WHERE CustomNotifTypeName = 'NewSelfServiceRequest'].Id;

    Set<String> serviceAgentsIdsSet = new Set<String>();
    for(Service_Agent_Id__mdt mdI : [SELECT User_Id__c FROM Service_Agent_Id__mdt ]){
        serviceAgentsIdsSet.add(mdI.User_Id__c);
    }

    for(Case ssr : Trigger.new){
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody('This is body of the custom notification!');
        notification.setTitle('Hi this is first notification sent using apex!');
        // notification.setSenderId(Userinfo.getUserId()); //    Id of the sender of this notification - optional
        notification.setNotificationTypeId(typeId);
        notification.setTargetId(ssr.Id); // target object id - will redirect to the record's detail/view page - default behavior
        notification.send(serviceAgentsIdsSet); // target user id.
    }

}