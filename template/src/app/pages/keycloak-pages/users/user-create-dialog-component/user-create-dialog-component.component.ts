import { Component, EventEmitter, OnInit, Optional, Output } from '@angular/core';
import { FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { MultiSelectModule } from 'primeng/multiselect';
import { PasswordModule } from 'primeng/password';
import { RxFormBuilder, RxFormGroup } from '@rxweb/reactive-form-validators';
import { KeycloakUserGroupView } from '../model/request/user-model-created';
import { ExposeControlDirective } from '../../../../common/expose-control-directive';
import { InputFormControlComponent } from '../../../../common/input-form-control';
import { UserService } from '../services/user-service';
import { MessageService } from 'primeng/api';
import { DialogService, DynamicDialogConfig, DynamicDialogRef } from 'primeng/dynamicdialog';
import { CardModule } from 'primeng/card';
import { SelectModule } from 'primeng/select';
import { GroupsService } from '../../groups/services/groups.service';
import { CommonModule } from '@angular/common';
import { environment } from '../../../../../environments/environment.development';
import { TreeSelectModule } from 'primeng/treeselect';
import { UserGroupAdd } from '../model/request/user-group-add';
import { GroupsDetail } from '../../groups/models/groups-created';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-user-create-dialog-component',
    imports: [
        FormsModule,
        ReactiveFormsModule,
        DialogModule,
        InputTextModule,
        PasswordModule,
        MultiSelectModule,
        ButtonModule,
        ExposeControlDirective,
        InputFormControlComponent,
        CardModule,
        CommonModule,
        SelectModule,
        TreeSelectModule,
        TranslateModule
    ],
    providers: [DialogService],
    templateUrl: './user-create-dialog-component.component.html',
    styleUrl: './user-create-dialog-component.component.scss'
})
export class UserCreateDialogComponent implements OnInit {
    passwordBackup: string | null | undefined;
    userFormGroup!: RxFormGroup;
    userDTO = new KeycloakUserGroupView();
    titolo: string = '';

    @Output() userCreated = new EventEmitter<any>();

    groups: any = [];

    companies: any = [];
    event: any;
    statusCompany: any[] = [
        { id: true, name: 'Attivo' },
        { id: false, name: 'Disattivato' }
    ];
    statusAccount: any[] = [
        { id: true, name: 'Attivo' },
        { id: false, name: 'Disattivato' }
    ];

    userGroupAdd = new UserGroupAdd();
    userFormGroupAdd!: RxFormGroup;
    constructor(
        private formBuilder: RxFormBuilder,
        private userService: UserService,
        private messageService: MessageService,
        @Optional() public ref: DynamicDialogRef,
        public dialogService: DialogService,
        private groupService: GroupsService,
        public config: DynamicDialogConfig,
        private translate: TranslateService
    ) {}
    users: any;
    ngOnInit(): void {
        this.users = this.config?.data?.users;
        console.log('Users ricevuti:', this.users);
        this.event = this.config?.data?.event;
        console.log('Evento ricevuto:', this.event);
        const request: any = {
            realm_id: environment.keycloak.realm,
            page: 0,
            size: 2147483647,
            sort: 'groupID',
            direction: 'ASC'
        };
        this.groupService.get(request).subscribe({
            next: (groups) => {
                this.groups = groups['content']
                    .filter((items) => items.groupName && items.distributionCompanyID === this.users?.distributionCompanyId)
                    .map((items) => ({
                        name: items.groupPath ? items.groupName! + '/' + items.groupPath : items.groupName!,
                        id: items.groupId!
                    }));
                this.companies = [
                    ...new Map(
                        groups['content']
                            .filter((items) => items.distributionCompanyID)
                            .map((items) => [
                                items.distributionCompanyID!,
                                {
                                    id: items.distributionCompanyID!,
                                    name: items.distributionCompanyName
                                }
                            ])
                    ).values()
                ];
                switch (this.event) {
                    case 'edit':
                        this.prepareForm({ disableForm: false });
                        break;

                    case 'view':
                        this.prepareForm({ disableForm: true });
                        break;

                    case 'delete':
                        break;
                    case 'add':
                        this.prepareFormAddDistribution();
                        break;
                    default:
                        Object.setPrototypeOf(this.userDTO, KeycloakUserGroupView.prototype);
                        this.userFormGroup = this.formBuilder.formGroup(this.userDTO) as RxFormGroup;
                        if (this.event !== 'create' && this.event !== 'edit') {
                            const distributionCompanyId = this.userFormGroup.get('distributionCompanyId');
                            const fromGroupId = this.userFormGroup.get('fromGroupId');
                            distributionCompanyId?.clearValidators();
                            distributionCompanyId?.updateValueAndValidity();
                            fromGroupId?.clearValidators();
                            fromGroupId?.updateValueAndValidity();
                        }
                        break;
                }
            }
        });
        console.log(this.userFormGroup);
    }
    prepareFormAddDistribution() {
        this.groups = [];
        this.userService.distributionNotIn(this.users.userId).subscribe({
            next: (groups) => {
                this.companies = [
                    ...new Map(
                        groups
                            .filter((items: GroupsDetail) => items.distributionCompanyID)
                            .map((items: GroupsDetail) => [
                                items.distributionCompanyID!,
                                {
                                    id: items.distributionCompanyID!,
                                    name: items.distributionCompanyName
                                }
                            ])
                    ).values()
                ];
            }
        });
        Object.setPrototypeOf(this.userGroupAdd, UserGroupAdd.prototype);
        this.userFormGroupAdd = this.formBuilder.formGroup(this.userGroupAdd) as RxFormGroup;
        this.userFormGroupAdd.get('groupIds')?.disable();
        this.userFormGroupAdd.get('groupIds')?.patchValue(null);
    }

    private prepareForm(options: { disableForm?: boolean }) {
        this.userDTO = this.users;
        this.passwordBackup = this.userDTO.password;
        this.userDTO.fromDistributionCompanyId = this.users?.distributionCompanyId;
        const foundCompany = this.companies.find((c: any) => c.id === this.users?.distributionCompanyId);
        this.userDTO.toDistributionCompanyIds = foundCompany ? (options.disableForm ? foundCompany.id : foundCompany.id) : null;
        const matchedGroup = this.groups.find((group: any) => group.name === this.users.groupName);
        this.userDTO.toGroupId = matchedGroup?.id ? [matchedGroup?.id] : [];
        this.userDTO.fromGroupId = this.users?.groupId;
        Object.setPrototypeOf(this.userDTO, KeycloakUserGroupView.prototype);
        this.userFormGroup = this.formBuilder.formGroup(this.userDTO) as RxFormGroup;

        const passwordControl = this.userFormGroup.get('password');
        const identityProviderControl = this.userFormGroup.get('identityProvider');
        if (passwordControl && identityProviderControl) {
            const identityProviderValue = identityProviderControl.value;
            if (identityProviderValue == null) {
                passwordControl.setValidators(Validators.required);
                passwordControl.enable();
            } else {
                passwordControl.clearValidators();
                passwordControl.disable();
            }

            passwordControl.updateValueAndValidity();
        }
        if (options.disableForm) {
            this.userFormGroup.disable();
        }

        const fromDistributionCompanyId = this.userFormGroup.get('distributionCompanyId');

        const fromGroupId = this.userFormGroup.get('fromGroupId');
        if (fromDistributionCompanyId?.value == null) {
            fromDistributionCompanyId?.clearValidators();
            fromDistributionCompanyId?.updateValueAndValidity();
        }
        if (fromGroupId?.value == null) {
            fromGroupId?.clearValidators();
            fromGroupId?.updateValueAndValidity();
        }
        if (this.userDTO.toGroupId.length == 0) {
            this.userFormGroup.get('toGroupId')?.disable();
        }
    }

    close() {
        if (this.userFormGroup) {
            this.userFormGroup.reset();
        } else if (this.userFormGroupAdd) {
            this.userFormGroupAdd.reset();
        }

        this.ref.close();
    }

    createUser() {
        if (this.userFormGroup.valid) {
            this.userService.createUser(this.userFormGroup.value).subscribe({
                next: (items) => {
                    this.messageService.add({
                        severity: 'success',
                        summary: this.translate.instant('common.success'),
                        detail: this.translate.instant('pages.modal_user.toast.create_success_detail')
                    });
                    this.userCreated.emit(this.userFormGroup.value);
                    this.close();
                },
                error: (err) => console.error('Errore nella chiamata :', err)
            });
        }
    }

    updateUser() {
        console.log(this.userFormGroup.value);
        this.userDTO = this.userFormGroup.value;
        if (this.userDTO!.password === this.passwordBackup) {
            this.userDTO!.password = null;
        }
        this.userService.updateUser(this.userDTO).subscribe({
            next: (items) => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('pages.modal_user.toast.success_updated'),
                    detail: this.translate.instant('pages.modal_user.toast.update_success_detail')
                });
                this.close();
            },
            error: (err) => console.error('Errore nella chiamata :', err)
        });
    }
    onCompaniesChange(event: any): void {
        const selectedIds: string = event.value;
        this.userFormGroup.get('toDistributionCompanyIds')?.patchValue(selectedIds);
        this.userFormGroup.get('toGroupId')?.disable();
        this.userFormGroup.get('toGroupId')?.patchValue(null);
        this.groupService.getGroupsAndSubGroupFromDistributionCommpanyID(selectedIds).subscribe({
            next: (value: Record<string, string>) => {
                this.groups = Object.entries(value ?? {}).map(([id, path]) => ({
                    id: id,
                    name: path
                }));

                this.userFormGroup.get('toGroupId')?.enable();
            }
        });
    }

    onCompaniesChangeAdd(event: any) {
        const selectedIds: string = event.value;
        if (selectedIds == null) {
            this.userFormGroupAdd.get('groupIds')?.disable();
            this.userFormGroupAdd.get('groupIds')?.patchValue(null);
        } else {
            this.userFormGroupAdd.get('distributionId')?.patchValue(selectedIds);
            this.userFormGroupAdd.get('groupIds')?.disable();
            this.userFormGroupAdd.get('groupIds')?.patchValue(null);
            this.groupService.getGroupsAndSubGroupFromDistributionCommpanyID(selectedIds).subscribe({
                next: (value: Record<string, string>) => {
                    this.groups = Object.entries(value ?? {}).map(([id, path]) => ({
                        id: id,
                        name: path
                    }));
                    this.userFormGroupAdd.get('groupIds')?.enable();
                }
            });
        }
    }

    addDistribution() {
        const groupIds = this.userFormGroupAdd.get('groupIds')?.value as string[];
        const payload = { groupIds };
        this.userService.addUserToGroups(this.users.userId, payload).subscribe({
            next: (value) => {},
            complete: () => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('common.success'),
                    detail: this.translate.instant('pages.modal_user.toast.add_distribution_success_detail')
                });
                this.ref.close();
            },
            error: (err) => {
                console.error(err);
            }
        });
    }
}
