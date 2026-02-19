import { CommonModule } from '@angular/common';
import { Component, Optional } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RxFormBuilder, RxFormGroup } from '@rxweb/reactive-form-validators';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { DialogModule } from 'primeng/dialog';
import { DialogService, DynamicDialogConfig, DynamicDialogRef } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { MultiSelectModule } from 'primeng/multiselect';
import { PasswordModule } from 'primeng/password';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';
import { TabsModule } from 'primeng/tabs';
import { ExposeControlDirective } from '../../../../common/expose-control-directive';
import { InputFormControlComponent } from '../../../../common/input-form-control';
import { RolesService } from '../../roles/service/roles-service';
import { GroupAttributesTabComponent } from '../group-attributes-tab/group-attributes-tab.component';
import { GroupsService } from '../services/groups.service';
import { AttributeRow, GroupsDetail } from '../models/groups-created';
import { environment } from '../../../../../environments/environment.development';
import { SubGroupObject } from './subGroup';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { ChipModule } from 'primeng/chip';

@Component({
    selector: 'app-group-dialog-create-subgroup',
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
        ChipModule,
        TableModule,
        TabsModule,
        GroupAttributesTabComponent,
        TranslateModule
    ],
    templateUrl: './group-dialog-create-subgroup.component.html',
    styleUrl: './group-dialog-create-subgroup.component.scss'
})
export class GroupDialogCreateSubgroupComponent {
    activeTab: '0' | '1' = '0';
    groupsFormGroup!: RxFormGroup;
    groups = new GroupsDetail();
    subGroup = new SubGroupObject();
    event: 'view' | 'edit' | 'create' | 'add' | any;
    roleList: { label: string; value: string }[] = [];
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
        this.groups = this.config?.data?.groups;
        this.subGroup.distributionCompanyName = this.groups.distributionCompanyName;
        this.subGroup.groupName = this.groups.subGroupName ? this.groups.subGroupName : this.groups.groupName;
        this.subGroup.groupId = this.groups.groupId;
        this.event = this.config?.data?.event;
        this.prepareGroupForm();
    }
    private prepareGroupForm() {
        Object.setPrototypeOf(this.subGroup, SubGroupObject.prototype);
        this.groupsFormGroup = this.formBuilder.formGroup(this.subGroup) as RxFormGroup;
        const request: any = {
            realm_id: environment.keycloak.realm,
            page: 0,
            size: 2147483647,
            sort: 'id',
            direction: 'ASC'
        };

        this.groupsFormGroup.get('distributionCompanyName')?.disable();
        this.groupsFormGroup.get('groupName')?.disable();
        this.roleService.get(request).subscribe({
            next: (value) => {
                const roles = value['content'];
                this.roleList = roles.map((role: any) => ({
                    label: role.roleName,
                    value: role.roleId
                }));
                const selectedRoleNames = this.subGroup.roles ?? [];
                const matchingIds = roles.filter((role: any) => selectedRoleNames.includes(role.roleName)).map((role: any) => role.roleId);

                this.groupsFormGroup.controls['roles'].setValue(matchingIds);
            },
            error: (err) => console.error('Errore durante il caricamento dei ruoli:', err)
        });
    }
    close() {
        this.ref.close();
    }
    rows: AttributeRow[] = [];
    createdSubGroups() {
        const formValue = this.groupsFormGroup.getRawValue();
        const attributes = this.rows.filter((r) => r.key?.trim()).map((r) => ({ ...(r.id ? { id: r.id } : {}), name: r.key.trim(), value: r.value ?? '' }));

        const payload = { ...formValue, attributes };

        this.groupService.createSubGroup(payload, this.subGroup.groupId!).subscribe({
            next: () => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('pages.modal_groups.toast.create_success_summary'),
                    detail: this.translate.instant('pages.modal_groups.toast.create_success_detail')
                });
                this.close();
            }
        });
    }
    /** Gestione del click “Salva attributi” nel componente figlio */
    onSaveAttributes(attrs: Array<{ id?: string; name: string; value: string }>) {
        if (this.groupsFormGroup.invalid) {
            this.messageService.add({
                severity: 'warn',
                summary: this.translate.instant('pages.modal_groups.toast.warn_summary'),
                detail: this.translate.instant('pages.modal_groups.toast.fill_required_fields')
            });
        } else {
            this.createdSubGroups();
        }

        /* const payload = { groupId: this.groups.groupId, attributes: attrs };
        console.log(payload);
        if (this.event === 'edit') {
            this.groupService.updateAttr(this.groups.groupId!, payload).subscribe({
                next: () => {
                    this.messageService.add({ severity: 'success', summary: 'Attributi aggiornati', detail: 'Gli attributi sono stati aggiornati con successo' });
                },
                error: (error) => console.error('Errore update attributi', error)
            });
        } */
    }
}
