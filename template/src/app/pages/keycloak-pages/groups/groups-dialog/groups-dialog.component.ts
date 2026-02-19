import { CommonModule } from '@angular/common';
import { Component, EventEmitter, OnInit, Optional, Output } from '@angular/core';
import { FormsModule, ReactiveFormsModule, Validators } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { CardModule } from 'primeng/card';
import { DialogModule } from 'primeng/dialog';
import { DialogService, DynamicDialogConfig, DynamicDialogRef } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { MultiSelectModule } from 'primeng/multiselect';
import { PasswordModule } from 'primeng/password';
import { SelectModule } from 'primeng/select';
import { ExposeControlDirective } from '../../../../common/expose-control-directive';
import { InputFormControlComponent } from '../../../../common/input-form-control';
import { RxFormBuilder, RxFormGroup } from '@rxweb/reactive-form-validators';
import { AttributeRow, GroupAttribute, GroupsDetail } from '../models/groups-created';
import { MessageService } from 'primeng/api';
import { GroupsService } from '../services/groups.service';
import { RolesService } from '../../roles/service/roles-service';
import { environment } from '../../../../../environments/environment.development';
import { TableModule } from 'primeng/table';
import { TabsModule } from 'primeng/tabs';
import { GroupAttributesTabComponent } from '../group-attributes-tab/group-attributes-tab.component';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { TooltipModule } from 'primeng/tooltip';
import { ChipModule } from 'primeng/chip';

@Component({
    selector: 'app-groups-dialog',
    standalone: true,
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
        TranslateModule,
        TooltipModule
    ],
    providers: [DialogService],
    templateUrl: './groups-dialog.component.html',
    styleUrl: './groups-dialog.component.scss'
})
export class GroupsDialogComponent implements OnInit {
    values: string[] = [];
    activeTab: '0' | '1' = '0';

    groupsFormGroup!: RxFormGroup;
    groups = new GroupsDetail();
    event: 'view' | 'edit' | 'create' | any;
    @Output() groupsReturned = new EventEmitter<any>();
    roleList: { label: string; value: string }[] = [];

    rows: AttributeRow[] = [];

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
        this.event = this.config?.data?.event;
        this.rows = this.mapAttributesToRows(this.groups?.attributesCurrent);

        switch (this.event) {
            case 'view':
                this.prepareGroupForm(true);
                break;
            case 'edit':
                this.prepareGroupForm(false);
                break;
            case 'create':
                this.prepareCreateGroupForm(false);
                break;
        }
    }

    getSubGroupsArray(): string[] {
        const value = this.groupsFormGroup.get('subGroupName')?.value;
        if (!value || typeof value !== 'string') return [];
        return value
            .split(';')
            .map((v) => v.trim())
            .filter((v) => v);
    }

    private prepareGroupForm(disableForm: boolean) {
        Object.setPrototypeOf(this.groups, GroupsDetail.prototype);
        this.groupsFormGroup = this.formBuilder.formGroup(this.groups) as RxFormGroup;
        const subGroupName = this.groupsFormGroup.get('subGroupName');
        if (!this.groups.subGroupName) {
            this.groupsFormGroup.get('subGroupName')?.disable();
            subGroupName!.clearValidators();
            subGroupName!.disable();
        } else if (this.groups.subGroupName) {
            this.groupsFormGroup.get('groupName')?.disable();
            subGroupName!.setValidators(Validators.required);
            subGroupName?.enable();
        }
        subGroupName!.updateValueAndValidity();
        const request: any = {
            realm_id: environment.keycloak.realm,
            page: 0,
            size: 2147483647,
            sort: 'id',
            direction: 'ASC'
        };

        this.groupsFormGroup.get('distributionCompanyName')?.disable();

        this.roleService.get(request).subscribe({
            next: (value) => {
                const roles = value['content'];
                this.roleList = roles.map((role: any) => ({
                    label: role.roleName,
                    value: role.roleId
                }));

                if (disableForm) {
                    this.groupsFormGroup.disable();
                } else {
                    const selectedRoleNames = this.groups.roles ?? [];
                    const matchingIds = roles.filter((role: any) => selectedRoleNames.includes(role.roleName)).map((role: any) => role.roleId);

                    this.groupsFormGroup.controls['roles'].setValue(matchingIds);
                }
            },
            error: (err) => console.error('Errore durante il caricamento dei ruoli:', err)
        });
    }

    private prepareCreateGroupForm(disableForm: boolean) {
        Object.setPrototypeOf(this.groups, GroupsDetail.prototype);
        this.groupsFormGroup = this.formBuilder.formGroup(this.groups) as RxFormGroup;
        const subGroupName = this.groupsFormGroup.get('subGroupName');

        const request: any = {
            realm_id: environment.keycloak.realm,
            page: 0,
            size: 2147483647,
            sort: 'id',
            direction: 'ASC'
        };

        this.groupsFormGroup.get('distributionCompanyName')?.disable();

        this.roleService.get(request).subscribe({
            next: (value) => {
                const roles = value['content'];
                this.roleList = roles.map((role: any) => ({
                    label: role.roleName,
                    value: role.roleId
                }));

                if (disableForm) {
                    this.groupsFormGroup.disable();
                } else {
                    const selectedRoleNames = this.groups.roles ?? [];
                    const matchingIds = roles.filter((role: any) => selectedRoleNames.includes(role.roleName)).map((role: any) => role.roleId);

                    this.groupsFormGroup.controls['roles'].setValue(matchingIds);
                }
            },
            error: (err) => console.error('Errore durante il caricamento dei ruoli:', err)
        });
    }

    createdGroups() {
        const formValue = this.groupsFormGroup.getRawValue();
        formValue.subGroupName = this.getSubGroupsArray();
        const attributes = this.rows.filter((r) => r.key?.trim()).map((r) => ({ ...(r.id ? { id: r.id } : {}), name: r.key.trim(), value: r.value ?? '' }));

        const payload = { ...formValue, attributes };

        this.groupService.post(payload).subscribe({
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

    updateGroups() {
        const formValue = this.groupsFormGroup.getRawValue();
        const attributes = this.rows.filter((r) => r.key?.trim()).map((r) => ({ ...(r.id ? { id: r.id } : {}), name: r.key.trim(), value: r.value ?? '' }));

        const payload = { ...formValue, attributes };

        this.groupService.update(payload, this.groups.groupId!).subscribe({
            next: () => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('common.success'),
                    detail: this.translate.instant('pages.modal_groups.toast.update_success_detail')
                });
                this.groupsReturned.emit(formValue);
                this.close();
            },
            error: (error) => console.error('errore ', error)
        });
    }

    private mapAttributesToRows(attrs?: GroupAttribute[] | unknown): AttributeRow[] {
        const safeAttrs = Array.isArray(attrs) ? attrs : [];
        return safeAttrs.map((a) => ({
            id: a?.id ?? null,
            key: a?.name ?? '',
            value: a?.value ?? ''
        }));
    }

    /** Gestione del click “Salva attributi” nel componente figlio */
    onSaveAttributes(attrs: Array<{ id?: string; name: string; value: string }>) {
        if (this.groupsFormGroup.invalid) {
            this.messageService.add({
                severity: 'warn',
                summary: this.translate.instant('pages.modal_groups.toast.warn_summary'),
                detail: this.translate.instant('pages.modal_groups.toast.fill_required_fields')
            });
        } else if (this.event === 'edit') {
            this.updateGroups();
            /*   const payload = { groupId: this.groups.groupId, attributes: attrs };
            this.groupService.updateAttr(this.groups.groupId!, payload).subscribe({
                next: () => {
                    this.messageService.add({ severity: 'success', summary: 'Attributi aggiornati', detail: 'Gli attributi sono stati aggiornati con successo' });
                },
                error: (error) => console.error('Errore update attributi', error)
            });*/
        } else if (this.event === 'create' && !this.groupsFormGroup.invalid) {
            this.createdGroups();
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

    close() {
        this.ref?.close();
    }
}
