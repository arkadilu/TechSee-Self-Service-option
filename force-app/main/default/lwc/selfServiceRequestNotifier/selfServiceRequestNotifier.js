import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import SELF_SERVICE_REQUEST_CREATED_CHANNEL from '@salesforce/messageChannel/SelfServiceRequestCreated__c';

export default class SelfServiceRequestNotifier extends LightningElement {
    subscription = null;
    messageRecieved = 'init val';
    anotherField = 'init val';

    @wire(MessageContext)
    messageContext;

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            SELF_SERVICE_REQUEST_CREATED_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }
    handleMessage(message) {    // { message : '...', another : '...'}
        this.messageRecieved = message.message
        this.anotherField = message.another
    }
    connectedCallback() {
        this.subscribeToMessageChannel();
    }
}