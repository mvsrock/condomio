import { prop, required } from '@rxweb/reactive-form-validators';

export class SubGroupObject {
    @required()
    groupName?: string | undefined;
    @required()
    nameGroup?: string;
    @prop()
    roles?: string[];
    @prop()
    distributionCompanyName?: string;
    @required() groupId?: string;
}
