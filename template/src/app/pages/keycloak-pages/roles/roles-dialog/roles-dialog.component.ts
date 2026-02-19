import { Component, OnInit, Optional } from '@angular/core';
import { RxFormBuilder, RxFormGroup } from '@rxweb/reactive-form-validators';
import { MessageService } from 'primeng/api';
import { DialogService, DynamicDialogConfig, DynamicDialogRef } from 'primeng/dynamicdialog';
import { GroupsService } from '../../groups/services/groups.service';
import { RolesService } from '../service/roles-service';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { MultiSelectModule } from 'primeng/multiselect';
import { PasswordModule } from 'primeng/password';
import { SelectModule } from 'primeng/select';
import { ExposeControlDirective } from '../../../../common/expose-control-directive';
import { InputFormControlComponent } from '../../../../common/input-form-control';
import { RoleCreated } from '../models/roleRequest';
import { environment } from '../../../../../environments/environment.development';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-roles-dialog',
    imports: [FormsModule, ReactiveFormsModule, DialogModule, InputTextModule, PasswordModule, MultiSelectModule, ButtonModule, ExposeControlDirective, InputFormControlComponent, CardModule, CommonModule, SelectModule, TranslateModule],
    providers: [DialogService],
    templateUrl: './roles-dialog.component.html',
    styleUrl: './roles-dialog.component.scss'
})
export class RolesDialogComponent implements OnInit {
    roleRequest: RoleCreated = new RoleCreated();
    event: any;
    rolesFormGroup!: RxFormGroup;
    groupList: { label: string; value: string }[] = [];
    constructor(
        private formBuilder: RxFormBuilder,
        private messageService: MessageService,
        @Optional() public ref: DynamicDialogRef,
        public dialogService: DialogService,
        private groupService: GroupsService,
        public config: DynamicDialogConfig,
        private roleService: RolesService,
        private translate: TranslateService
    ) {}
    ngOnInit(): void {
        this.roleRequest = this.config?.data?.groups;
        this.event = this.config?.data?.event;
        switch (this.event) {
            case 'view':
                this.prepareGroupForm(true);
                break;
            case 'edit':
                this.prepareGroupForm(false);
                break;
            case 'created':
                this.prepareGroupForm(false);
                break;
        }
    }
    private prepareGroupForm(disableForm: boolean) {
        Object.setPrototypeOf(this.roleRequest, RoleCreated.prototype);
        this.rolesFormGroup = this.formBuilder.formGroup(this.roleRequest) as RxFormGroup;

        const request: any = {
            realm_id: environment.keycloak.realm,
            page: 0,
            size: 2147483647,
            sort: 'id',
            direction: 'ASC'
        };

        this.groupService.get(request).subscribe({
            next: (value) => {
                const groups = value['content'];

                this.groupList = groups
                    .filter((group) => group.groupName && group.groupId)
                    .map((group) => ({
                        label: group.subGroupName ? `${group.groupName}/${group.subGroupName}` : (group.groupName as string),
                        value: group.groupId as string
                    }));

                if (disableForm) {
                    this.rolesFormGroup.disable();
                } else {
                    const selectedGroupNames = this.roleRequest.groupIDs ?? [];

                    const matchingIds = groups
                        .filter((group) => group.groupName && group.groupId)
                        .filter((group) => {
                            const fullName = group.subGroupName ? `${group.groupName}/${group.subGroupName}` : (group.groupName as string);
                            return selectedGroupNames.includes(fullName);
                        })
                        .map((group) => group.groupId);

                    this.rolesFormGroup.controls['groupIDs'].setValue(matchingIds);
                }
            },
            error: (err) => {
                console.error('Errore durante il caricamento dei gruppi:', err);
            }
        });
    }

    close() {
        this.rolesFormGroup.reset();
        this.ref.close();
    }

    updateRoles() {
        console.log(this.rolesFormGroup.value);
        this.roleService.update(this.rolesFormGroup.value, this.rolesFormGroup.value.roleId).subscribe({
            next: (value) => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('pages.roles.toast.update_success_summary'),
                    detail: this.translate.instant('pages.roles.toast.update_success_detail')
                });
                this.close();
            }
        });
    }

    createRoles() {
        console.log(this.rolesFormGroup.value);
        this.roleService.created(this.rolesFormGroup.value).subscribe({
            next: (value) => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('pages.roles.toast.create_success_summary'),
                    detail: this.translate.instant('pages.roles.toast.create_success_detail')
                });
                this.close();
            }
        });
    }
}
