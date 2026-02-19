import { email, minLength, password, prop, required } from '@rxweb/reactive-form-validators';

export class KeycloakUserGroupView {
    @prop()
    id?: string;

    @required({ message: 'pages.modal_user.validation_required' })
    @email()
    email!: string;

    @prop()
    userId?: string;

    @required({ message: 'pages.modal_user.validation_required' })
    @minLength({ value: 3, message: 'pages.modal_user.validation_username_minlength' })
    username!: string;

    @required({ message: 'pages.modal_user.validation_required' })
    firstName?: string;

    @required({ message: 'pages.modal_user.validation_required' })
    lastName!: string;

    @required({ message: 'pages.modal_user.validation_required' })
    @password({
        validation: {
            maxLength: 12,
            minLength: 8,
            digit: true,
            specialCharacter: true
        },
        message: 'pages.modal_user.validation_password_rules'
    })
    password?: string | null;

    @required({ message: 'pages.modal_user.validation_required' })
    enabled!: boolean;

    @prop()
    groupName: string[] = [];

    @prop()
    distributionCompany?: string;

    @required({ message: 'pages.modal_user.validation_distribution_required' })
    distributionCompanyId?: number[];

    @prop()
    identityProvider?: string | null | undefined;

    @required({ message: 'pages.modal_user.validation_required' })
    fromGroupId?: string;

    @required({ message: 'pages.modal_user.validation_group_required' })
    toGroupId?: string[] = [];

    @required({ message: 'pages.modal_user.validation_distribution_required' })
    toDistributionCompanyIds?: number;

    @prop()
    fromDistributionCompanyId?: number;
}
