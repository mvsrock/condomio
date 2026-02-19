import { prop } from '@rxweb/reactive-form-validators';

export class MenuItemRequest {
    @prop()
    label?: string;
    @prop()
    parent?: string;
    @prop()
    roleId?: string;
    @prop()
    roleName?: string;
}
