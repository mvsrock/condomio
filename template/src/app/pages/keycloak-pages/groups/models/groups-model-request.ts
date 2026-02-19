import { prop } from '@rxweb/reactive-form-validators';

export class GroupsModelRequest {
    @prop()
    groupName?: string;
    @prop()
    roles?: string;
    @prop()
    groupPath?: string;
}
