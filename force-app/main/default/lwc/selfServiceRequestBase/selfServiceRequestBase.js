import { LightningElement, api, wire } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import uploadFile from '@salesforce/apex/selfServiceRequestUtils.uploadFile';

import SELF_SERVICE_REQUEST_OBJECT from '@salesforce/schema/Self_Service_Request__c';
import FIRST_NAME_FIELD from '@salesforce/schema/Self_Service_Request__c.FirstName__c';
import LAST_NAME_FIELD from '@salesforce/schema/Self_Service_Request__c.LastName__c';
import EMAIL_FIELD from '@salesforce/schema/Self_Service_Request__c.Email__c';
import PHONE_FIELD from '@salesforce/schema/Self_Service_Request__c.Phone__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Self_Service_Request__c.Description__c';

const OBJECT_FIELDS = [
    FIRST_NAME_FIELD,
    LAST_NAME_FIELD,
    EMAIL_FIELD,
    PHONE_FIELD,
    DESCRIPTION_FIELD,
]

export default class SelfServiceRequestBase extends LightningElement {
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: OBJECT_FIELDS }) self_service;
    
    uploadedFiles = [];

    get firstName() {
        return this.self_service?.data?.fields.FirstName__c.value
    }
    get lastName() {
        return this.self_service?.data?.fields.LastName__c.value
    }
    get phone() {
        return this.self_service?.data?.fields.Phone__c.value
    }
    get email() {
        return this.self_service?.data?.fields.Email__c.value
    }
    get description() {
        return this.self_service?.data?.fields.Description__c.value
    }


    //  self service request section
    handleSubmit(event) {
        console.log('SelfServiceRequestBase > ssr_handleSave')
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Saving...',
                message: 'Saving...',
                variant: 'info',
            })
        );
    }

    handleSuccess(event) {
        console.log('SelfServiceRequestBase > ssr_handleSuccess')
        let fthis = this

        let newelyCreatedSSR_Id = event.detail.id

        this.uploadedFiles = this.uploadedFiles.map(file => { return { ...file, recordId: newelyCreatedSSR_Id } })
        console.log('need to associate with SSR record ', [newelyCreatedSSR_Id, this.uploadedFiles])

        let _fileUploadPromises = [];
        Promise.allSettled(_fileUploadPromises)
            .then((results) => {
                results.map((result) => console.log('upload promise settled: ', result))
                fthis.uploadedFiles = []
                fthis.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Self Service Request created successfully!!',
                        variant: 'success',
                    })
                );
            })
            .catch(console.error)

        this.uploadedFiles.map(fileObj => {
            const { base64, filename, recordId } = fileObj
            _fileUploadPromises = [..._fileUploadPromises, uploadFile({ base64, filename, recordId })]
        })
        console.log('promises.. ', _fileUploadPromises)

    }

    openfileUpload(event) {
        let fthis = this
        console.log('SelfServiceRequestBase > openfileUpload');

        const file = event.target.files[0]

        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            fthis.uploadedFiles = fthis.uploadedFiles.concat({
                'filename': file.name,
                'base64': base64,
                'recordId': '',
                'key': fthis.uploadedFiles.length,
            })
            console.log('openfileUpload.. ', { ...fthis.uploadedFiles })
        }
        reader.readAsDataURL(file)
    }

    handleError(event) {
        console.log('SelfServiceRequestBase > handleError');
        console.log(event.detail);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating records',
                message: event.detail.message,
                variant: 'error',
            })
        );
    }
}