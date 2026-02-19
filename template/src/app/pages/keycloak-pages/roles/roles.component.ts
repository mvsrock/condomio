import { Component, OnDestroy, OnInit, Optional } from '@angular/core';
import { LazyLoadWithPageEvent, ReusableTableComponent } from '../../../common/reusable-table/reusable-table.component';
import { RolesService } from './service/roles-service';
import { environment } from '../../../../environments/environment.development';
import { RoleCreated, RoleRequest } from './models/roleRequest';
import { RxFormBuilder, RxFormGroup } from '@rxweb/reactive-form-validators';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { InputText } from 'primeng/inputtext';
import { ExposeControlDirective } from '../../../common/expose-control-directive';
import { InputFormControlComponent } from '../../../common/input-form-control';
import { GroupsService } from '../groups/services/groups.service';
import { MultiSelectModule } from 'primeng/multiselect';
import { FloatLabelModule } from 'primeng/floatlabel';
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';
import { RolesDialogComponent } from './roles-dialog/roles-dialog.component';
import { ConfirmationService, MessageService } from 'primeng/api';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import _ from 'lodash';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-roles',
    imports: [ReusableTableComponent, ReactiveFormsModule, InputText, ButtonModule, InputFormControlComponent, ExposeControlDirective, CommonModule, MultiSelectModule, FloatLabelModule, ConfirmDialogModule, TranslateModule],
    providers: [DialogService, ConfirmationService],
    templateUrl: './roles.component.html',
    styleUrl: './roles.component.scss'
})
export class RolesComponent implements OnInit, OnDestroy {
    groupList: any[] = [];
    sizePage = 10;
    totalRecords = 0;
    loading = false;
    page = 0;
    sort = 'roleName';
    direction = 1;
    directionDB: string = this.direction == 1 ? 'ASC' : 'DESC';
    rolesItems: any;
    tableColumns: any[] = [];
    totalPage: number = 0;
    actions: any[] = [];
    roleRequest = new RoleRequest();
    rolesFormGroup!: RxFormGroup;

    private langSub?: Subscription;

    constructor(
        public dialogService: DialogService,
        @Optional() public ref: DynamicDialogRef,
        private groupService: GroupsService,
        private roleService: RolesService,
        private formBuilder: RxFormBuilder,
        private messageService: MessageService,
        private confirmationService: ConfirmationService,
        private translate: TranslateService
    ) {}

    ngOnInit(): void {
        this.getGroupsComboBox();

        Object.setPrototypeOf(this.roleRequest, RoleRequest.prototype);
        this.rolesFormGroup = this.formBuilder.formGroup(this.roleRequest) as RxFormGroup;

        this.buildTableColumns();
        this.buildActions();

        this.langSub = this.translate.onLangChange.subscribe(() => {
            this.buildTableColumns();
            this.buildActions();
        });
        this.reloadTable();
    }

    ngOnDestroy(): void {
        this.langSub?.unsubscribe();
    }

    private buildTableColumns(): void {
        this.tableColumns = [
            { field: 'roleName', header: this.translate.instant('pages.roles.table.header_role_name'), sortField: 'roleName' },
            { field: 'groupIDs', header: this.translate.instant('pages.roles.table.header_group'), sortField: 'groupName' }
        ];
    }

    private buildActions(): void {
        this.actions = [
            { icon: 'pi pi-eye', tooltip: this.translate.instant('common.view'), eventName: 'view' },
            { icon: 'pi pi-pencil', tooltip: this.translate.instant('common.edit'), eventName: 'edit' },
            { icon: 'pi pi-trash', tooltip: this.translate.instant('common.delete'), eventName: 'delete', styleClass: 'p-button-danger p-button-sm' }
        ];
    }

    getGroupsComboBox(): void {
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
                    .filter((items) => items.groupName)
                    .map((items) => ({
                        label: items.groupPath ? `${items.groupName}/${items.groupPath}` : items.groupName,
                        value: items.groupPath ? `${items.groupName}/${items.groupPath}` : items.groupName
                    }));
            }
        });
    }

    reloadTable(): void {
        this.loading = true;
        const filters = this.rolesFormGroup.value;
        const request: any = {
            ...filters,
            realm_id: environment.keycloak.realm,
            page: this.page,
            size: this.sizePage,
            sort: this.sort,
            direction: this.directionDB
        };

        this.roleService.get(request).subscribe({
            next: (items) => {
                this.rolesItems = items['content'];
                this.totalRecords = items['totalElements'];
                this.sizePage = items['pageSize'];
                this.page = items['pageNumber'];
                this.totalPage = items['totalPages'];
                this.loading = false;
            },
            error: (err) => console.error('Error in call:', err)
        });
    }

    handleLazyLoad(event: LazyLoadWithPageEvent): void {
        this.sort = event.sortField as string;
        this.directionDB = event.sortOrder == 1 ? 'ASC' : 'DESC';
        this.page = event.currentPage;
        this.sizePage = event.rows as number;
        this.reloadTable();
    }

    handleAction(event: any): void {
        switch (event.action) {
            case 'edit':
                this.openDialog(this.translate.instant('pages.roles.dialog.edit'), event);
                break;

            case 'view':
                this.openDialog(this.translate.instant('pages.roles.dialog.view'), event);
                break;

            case 'delete':
                const roleName = event.rowData?.roleName ?? '';
                this.confirmationService.confirm({
                    header: this.translate.instant('pages.roles.confirm.delete_header', { roleName }),
                    message: this.translate.instant('pages.roles.confirm.delete_message', { roleName }),
                    icon: 'pi pi-exclamation-triangle',
                    acceptLabel: this.translate.instant('common.accept'),
                    rejectLabel: this.translate.instant('common.reject'),
                    accept: () => {
                        this.roleService.deleted(event?.rowData.roleId).subscribe({
                            next: () => {
                                this.messageService.add({
                                    severity: 'success',
                                    summary: this.translate.instant('pages.roles.toast.delete_success_summary'),
                                    detail: this.translate.instant('pages.roles.toast.delete_success_detail')
                                });
                                this.reloadTable();
                            },
                            error: (err) => {
                                console.error('Error deleting role:', err);
                                this.messageService.add({
                                    severity: 'error',
                                    summary: this.translate.instant('pages.roles.toast.error_summary'),
                                    detail: this.translate.instant('pages.pages.roles.toast.delete_error_detail')
                                });
                            }
                        });
                    }
                });
                break;

            default:
                this.reloadTable();
                break;
        }
    }

    private openDialog(header: string, event?: any): void {
        const _roles = _.cloneDeep(event?.rowData);
        this.ref = this.dialogService.open(RolesDialogComponent, {
            header,
            width: '700px',
            height: '700px',
            contentStyle: { overflow: 'auto' },
            baseZIndex: 10000,
            data: {
                groups: _roles,
                event: event?.action
            },
            maximizable: true,
            closable: true
        });

        this.ref.onClose.subscribe(() => {
            this.ref?.destroy();
            this.reloadTable();
        });
    }

    gropusVisibilityFn = (): boolean => true;

    submit(): void {
        this.reloadTable();
    }

    reset(): void {
        this.rolesFormGroup.reset();
        this.reloadTable();
    }

    addRole(): void {
        this.openDialog(this.translate.instant('pages.roles.dialog.create'), { rowData: new RoleCreated(), action: 'created' });
    }
}
