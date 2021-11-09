public with sharing class selfServiceRequestUtils implements Queueable{

  public List<Self_Service_Request__c> newSSRList = new List<Self_Service_Request__c>();

  public selfServiceRequestUtils(List<Self_Service_Request__c> newRecords){
    newSSRList = newRecords;
  }

  public void execute(QueueableContext qc){
    Id typeId = [SELECT Id FROM CustomNotificationType WHERE CustomNotifTypeName = 'NewSelfServiceRequest'].Id;

    Set<String> serviceAgentsIdsSet = new Set<String>();
    for(Service_Agent_Id__mdt mdI : [SELECT User_Id__c FROM Service_Agent_Id__mdt ]){
        serviceAgentsIdsSet.add(mdI.User_Id__c);
    }

    system.debug('typeId '+typeId);
    system.debug('serviceAgentsIdsSet '+serviceAgentsIdsSet);
    system.debug('newSSRList '+newSSRList[0]);

    for(Self_Service_Request__c ssr : newSSRList){
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody('A request was just created by an end user using the Self Service option in the Experience cloud!');
        notification.setTitle('This requires your attention!');
        // notification.setSenderId(Userinfo.getUserId()); //    Id of the sender of this notification - optional
        notification.setNotificationTypeId(typeId);
        notification.setTargetId(ssr.Id); // target object id - will redirect to the record's detail/view page - default behavior
        notification.send(serviceAgentsIdsSet); // target user id.
    }

   }
  
    // public class customContentWrapper {
    //     String contentVersionId;
    //     String documentId;
    //     String name;
    // }

    // public class customResponseWrapper {
    //     public customResponseWrapper(Boolean success,String error){
    //         this.success=success;
    //         this.error=error;
    //     }

    //     Boolean success;
    //     String error;
    // }

    // @AuraEnabled(cacheable=true)
    // public static List<ContentDocumentLink> associateFilesWithCaseRecord(Id caseId, List<customContentWrapper> uploadedFilesList){
    //     Id docId = '0698d000000DrUsAAK';

    //     return new List<ContentDocumentLink>([
    //         Select Id,ContentDocument.CreatedBy.Name,ContentDocument.CreatedDate,ContentDocument.Title,ContentDocument.ContentSize, ContentDocument.FileExtension
    //         From ContentDocumentLink
    //         Where LinkedEntityId = :docId
    //     ]);
    // }

     /*
   * @method uploadFile() 
   * @desc Creates a content version from a given file's base64 and name
   * 
   * @param {String} base64 - base64 string that represents the file
   * @param {String} filename - full file name with extension, i.e. 'products.csv'
   * @param {String} recordId - Id of the record you want to attach this file to
   * 
   * @return {ContentVersion} - returns the created ContentDocumentLink Id if the
   *   upload was successful, otherwise returns null
   */
   @AuraEnabled
   public static String uploadFile(String base64, String filename, String recordId) {
     try {
       ContentVersion cv = createContentVersion(base64, filename);
         ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
         if (cv == null || cdl == null) { return null; }
         system.debug('upload finished');
         return 'true';
     } catch (Exception e) {
       system.debug('exception '+JSON.serialize(e));
       return JSON.serialize(e);
     }
   }
   /*
    * @method createContentVersion() [private]
    * @desc Creates a content version from a given file's base64 and name
    * 
    * @param {String} base64 - base64 string that represents the file
    * @param {String} filename - full file name with extension, i.e. 'products.csv'
    * 
    * @return {ContentVersion} - returns the newly created ContentVersion, or null
    *   if there was an error inserting the record
    */
   private static ContentVersion createContentVersion(String base64, String filename) {
     ContentVersion cv = new ContentVersion();
     cv.VersionData = EncodingUtil.base64Decode(base64);
     cv.Title = filename;
     cv.PathOnClient = filename;
     try {
       insert cv;
       return cv;
     } catch(DMLException e) {
       System.debug(e);
       return null;
     }
   }
 
    /*
    * @method createContentLink() [private]
    * @desc Creates a content link for a given ContentVersion and record
    * 
    * @param {String} contentVersionId - Id of the ContentVersion of the file
    * @param {String} recordId - Id of the record you want to attach this file to
    * 
    * @return {ContentDocumentLink} - returns the newly created ContentDocumentLink, 
    *   or null if there was an error inserting the record
    */
   private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
               if (contentVersionId == null || recordId == null) { return null; }
     ContentDocumentLink cdl = new ContentDocumentLink();
     cdl.ContentDocumentId = [
       SELECT ContentDocumentId 
       FROM ContentVersion 
       WHERE Id =: contentVersionId
     ].ContentDocumentId;
     cdl.LinkedEntityId = recordId;
     // ShareType is either 'V', 'C', or 'I'
     // V = Viewer, C = Collaborator, I = Inferred
     cdl.ShareType = 'V';
     try {
       insert cdl;
       return cdl;
     } catch(DMLException e) {
       System.debug(e);
       return null;
     }
   }
   
}