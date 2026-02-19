import { prop, required } from '@rxweb/reactive-form-validators';

export interface GroupAttribute {
    id?: string | null;
    name: string;
    value: string;
}
export type AttributeRow = {
    id?: string | null;
    key: string;
    value: string;
};
export class GroupsCreated {
    @prop()
    groupId?: string;
    @required({ message: 'Nome del gruppo obbligatorio' })
    groupName?: string;
    @prop()
    realmId?: string;
    @prop()
    roles?: string[];
}

export class GroupSerch {
    groupId?: string;
    groupName?: string;
    subGroupName?: string;
    realmId?: string;
    roles?: string[];
    groupPath?: string;
    distributionCompanyID?: string;
    distributionCompanyName?: string;
}

export class GroupsDetail {
    @prop() groupId?: string;
    @required() groupName?: string;
    @prop() realmId?: string;
    @prop() roles?: string[];
    @required({ conditionalExpression: (x: GroupsDetail) => x.subGroupName !== null })
    subGroupName?: string;
    @prop() distributionCompanyName?: string;
    @prop() distributionCompanyID?: string;

    // dinamici
    @prop() attributesCurrent?: GroupAttribute[];
    @prop() attributesAll?: GroupAttribute[];
    @prop() grouppath?: string;
    @prop() groupPath?: string;
}

export class GroupsCreate {
    @required() groupName?: string;
    @prop() subGroupName?: string;
}
