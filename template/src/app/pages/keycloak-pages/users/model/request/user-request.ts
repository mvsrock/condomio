import { prop } from '@rxweb/reactive-form-validators';

export class UserRequestTable {
    @prop()
    email?: string;
    @prop()
    firstName?: string;
    @prop()
    lastName?: string;
    @prop()
    username?: string;
    @prop()
    groupName?: string;

    @prop()
    distributionCompany?: string;
}
