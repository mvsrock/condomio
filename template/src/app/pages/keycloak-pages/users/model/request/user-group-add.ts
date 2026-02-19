import { required } from '@rxweb/reactive-form-validators';

export class UserGroupAdd {
    @required()
    groupIds!: string[];

    @required()
    distributionId!: string;
}
