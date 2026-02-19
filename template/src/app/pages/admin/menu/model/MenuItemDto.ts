import { numeric, NumericValueType, prop, required } from '@rxweb/reactive-form-validators';

export class MenuItemDto {
    @prop()
    id?: number;
    item?: string;
    @required({ message: 'pages.modal_user.validation_required' })
    label?: string;
    @prop()
    description?: string;
    @prop()
    parent?: string;
    @prop()
    @numeric({ allowDecimal: false, acceptValue: NumericValueType.PositiveNumber })
    visualOrder: number = 0;
    @prop()
    uri?: string;
    @prop()
    icon?: string;
    realm?: string;
    @prop()
    parentId?: string;
    @required({ message: 'pages.modal_user.validation_required' })
    roleId?: string;
    @prop()
    roleName?: string;
    @required({ message: 'pages.modal_user.validation_required' })
    visible?: boolean;
}
