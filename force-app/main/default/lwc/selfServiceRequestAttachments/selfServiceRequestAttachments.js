import { LightningElement, api} from 'lwc';

export default class SelfServiceItemsUploader extends LightningElement {
    @api associateFilesWithCase

    @api recordId

    caseRecordId;

    get acceptedFormats() {
        return ['.img', '.png', '.mov','.mp4'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert('No. of files uploaded : ' + uploadedFiles.length);
    }
}