import { prop, required } from '@rxweb/reactive-form-validators';

export class RoleRequest {
    @prop()
    roleId?: string;
    @prop()
    roleName?: string;

    @prop()
    groupsName?: string[];
}

export class RoleCreated {
    @prop()
    roleId?: string;
    @required()
    roleName?: string;

    @prop()
    description?: string;

    @prop()
    realmId?: string;

    @prop()
    groupIDs?: string[];
}

export class KeycloakRoleGroupRequest {
    roleId?: string;

    roleName?: string;

    description?: string;

    realmId?: string;

    groupName?: string[];
}
