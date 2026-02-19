import { Component, OnDestroy, OnInit, Optional } from '@angular/core';
import { RxFormBuilder, RxFormGroup } from '@rxweb/reactive-form-validators';
import { ConfirmationService, MessageService } from 'primeng/api';
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';
import { GroupsService } from './services/groups.service';
import { ReusableTableComponent } from '../../../common/reusable-table/reusable-table.component';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { InputText } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { ExposeControlDirective } from '../../../common/expose-control-directive';
import { InputFormControlComponent } from '../../../common/input-form-control';
import { LazyLoadWithPageEvent } from '../../../common/reusable-table/LazyLoadWithPageEvent';
import { environment } from '../../../../environments/environment.development';
import { GroupsModelRequest } from './models/groups-model-request';
import { GroupsDialogComponent } from './groups-dialog/groups-dialog.component';
import { GroupsDetail, GroupSerch } from './models/groups-created';
import { RolesService } from '../roles/service/roles-service';
import { MultiSelectModule } from 'primeng/multiselect';
import { GroupDialogCreateSubgroupComponent } from './group-dialog-create-subgroup/group-dialog-create-subgroup.component';
import _ from 'lodash';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-groups',
    imports: [FormsModule, ReusableTableComponent, ReactiveFormsModule, InputText, ButtonModule, InputFormControlComponent, ExposeControlDirective, CommonModule, SelectModule, ConfirmDialogModule, MultiSelectModule, TranslateModule],
    providers: [DialogService, ConfirmationService],
    templateUrl: './groups.component.html',
    styleUrl: './groups.component.scss'
})
export class GroupsComponent implements OnInit, OnDestroy {
    sizePage = 10;
    totalRecords = 0;
    loading = false;
    page = 0;
    sort = 'distributionCompanyName';
    direction = 1;
    directionDB: string = this.direction == 1 ? 'ASC' : 'DESC';

    tableColumns: any[] = [];
    grousItems: GroupSerch[] = []; // lasciato invariato per compatibilità con il tuo template
    groupsRequest = new GroupsModelRequest();

    registeredUserActions: any[] = [];
    groupsFormGroup!: RxFormGroup;
    roleList: any[] = [];

    private langSub?: Subscription;
    totalPage: number = 0;
    constructor(
        public dialogService: DialogService,
        private formBuilder: RxFormBuilder,
        @Optional() public ref: DynamicDialogRef,
        private messageService: MessageService,
        private confirmationService: ConfirmationService,
        private groupService: GroupsService,
        private roleService: RolesService,
        private translate: TranslateService
    ) {}

    ngOnInit(): void {
        this.loading = true;
        this.getRolesComboBox();

        Object.setPrototypeOf(this.groupsRequest, GroupsModelRequest.prototype);
        this.groupsFormGroup = this.formBuilder.formGroup(this.groupsRequest) as RxFormGroup;

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
            { field: 'distributionCompanyName', header: this.translate.instant('pages.groups.table.header_company'), sortField: 'distributionCompanyName' },
            { field: 'groupName', header: this.translate.instant('pages.groups.table.header_main_group'), sortField: 'groupName' },
            { field: 'groupPath', header: this.translate.instant('pages.groups.table.header_subgroup'), sortField: 'groupPath' },
            { field: 'roles', header: this.translate.instant('pages.groups.table.header_roles'), sortField: 'roles' }
        ];
    }

    private buildActions(): void {
        this.registeredUserActions = [
            { icon: 'pi pi-plus', tooltip: this.translate.instant('pages.groups.actions.add_subgroup'), eventName: 'add' },
            { icon: 'pi pi-eye', tooltip: this.translate.instant('common.view'), eventName: 'view' },
            { icon: 'pi pi-pencil', tooltip: this.translate.instant('common.edit'), eventName: 'edit' },
            { icon: 'pi pi-trash', tooltip: this.translate.instant('common.delete'), eventName: 'delete', styleClass: 'p-button-danger p-button-sm' }
        ];
    }

    gropusVisibilityFn = (_action: string, _row: any): boolean => true;

    submit(): void {
        this.reloadTable();
    }

    reset(): void {
        this.groupsFormGroup.reset();
        this.reloadTable();
    }

    handleLazyLoad(event: LazyLoadWithPageEvent): void {
        this.sort = event.sortField as string;
        this.directionDB = event.sortOrder == 1 ? 'ASC' : 'DESC';
        this.page = event.currentPage;
        this.sizePage = event.rows as number;
        this.reloadTable();
    }

    reloadTable(): void {
        this.loading = true;
        const filterss = this.groupsFormGroup.value;
        const request: any = {
            ...filterss,
            page: this.page,
            size: this.sizePage,
            sort: this.sort,
            direction: this.directionDB
        };
        this.groupService.get(request).subscribe({
            next: (items) => {
                this.grousItems = items['content'];
                this.totalRecords = items['totalElements'];
                this.sizePage = items['pageSize'];
                this.page = items['pageNumber'];
                this.totalPage = items['totalPages'];
                this.loading = false;
            },
            error: (err) => console.error('Errore nella chiamata menu:', err)
        });
    }

    handleAction(event: any): void {
        switch (event.action) {
            case 'edit':
                if (!event.rowData.subGroupName && event.rowData.groupName) {
                    this.openGroupDialog(this.translate.instant('pages.groups.dialog.edit_group'), event);
                } else if (event.rowData.subGroupName && event.rowData.groupName) {
                    this.openGroupDialog(this.translate.instant('pages.groups.dialog.edit_subgroup'), event);
                }
                break;

            case 'view':
                this.openGroupDialog(this.translate.instant('pages.groups.dialog.view_group'), event);
                break;

            case 'delete':
                if (!event.rowData.subGroupName && event.rowData.groupName) {
                    const groupName = event.rowData?.groupName ?? '';
                    this.confirmationService.confirm({
                        header: this.translate.instant('pages.groups.confirm.delete_group_header', { groupName }),
                        message: this.translate.instant('pages.groups.confirm.delete_group_message', { groupName }),
                        icon: 'pi pi-exclamation-triangle',
                        acceptLabel: this.translate.instant('common.accept'),
                        rejectLabel: this.translate.instant('common.reject'),
                        accept: () => {
                            this.groupService.deleted(event?.rowData.groupId).subscribe({
                                next: () => {
                                    this.messageService.add({
                                        severity: 'success',
                                        summary: this.translate.instant('pages.groups.toast.delete_success_summary'),
                                        detail: this.translate.instant('pages.groups.toast.delete_success_detail')
                                    });
                                    this.reloadTable();
                                },
                                error: (err) => {
                                    console.error('Errore nella chiamata disabled:', err);
                                    this.messageService.add({
                                        severity: 'error',
                                        summary: this.translate.instant('pages.groups.toast.error_summary'),
                                        detail: this.translate.instant('pages.groups.toast.delete_error_detail')
                                    });
                                }
                            });
                        }
                    });
                } else if (event.rowData.subGroupName && event.rowData.groupName) {
                    const subGroupName = event.rowData?.subGroupName ?? '';
                    this.confirmationService.confirm({
                        header: this.translate.instant('pages.groups.confirm.delete_subgroup_header', { subGroupName }),
                        message: this.translate.instant('pages.groups.confirm.delete_subgroup_message', { subGroupName }),
                        icon: 'pi pi-exclamation-triangle',
                        acceptLabel: this.translate.instant('common.accept'),
                        rejectLabel: this.translate.instant('common.reject'),
                        accept: () => {
                            this.groupService.deleted(event?.rowData.groupId).subscribe({
                                next: () => {
                                    this.messageService.add({
                                        severity: 'success',
                                        summary: this.translate.instant('pages.groups.toast.delete_success_summary'),
                                        detail: this.translate.instant('pages.groups.toast.delete_success_detail')
                                    });
                                    this.reloadTable();
                                },
                                error: (err) => {
                                    console.error('Errore nella chiamata disabled:', err);
                                    this.messageService.add({
                                        severity: 'error',
                                        summary: this.translate.instant('pages.groups.toast.error_summary'),
                                        detail: this.translate.instant('pages.groups.toast.delete_error_detail')
                                    });
                                }
                            });
                        }
                    });
                }
                break;

            case 'add':
                this.openSubGroupDialog(this.translate.instant('pages.groups.dialog.create_subgroup'), event);
                break;

            default:
                this.reloadTable();
                break;
        }
    }

    addGroup(): void {
        this.openGroupDialog(this.translate.instant('pages.groups.dialog.create_group'), { rowData: new GroupsDetail(), action: 'create' });
    }

    private openGroupDialog(header: string, event?: any): void {
        const _group = _.cloneDeep(event?.rowData);
        this.ref = this.dialogService.open(GroupsDialogComponent, {
            header,
            width: 'auto',
            height: 'auto',
            contentStyle: { overflow: 'auto' },
            baseZIndex: 10000,
            data: { groups: _group, event: event?.action },
            maximizable: true,
            closable: true
        });

        this.ref.onClose.subscribe(() => {
            this.ref?.destroy();
            this.reloadTable();
        });
    }

    private openSubGroupDialog(header: string, event?: any): void {
        this.ref = this.dialogService.open(GroupDialogCreateSubgroupComponent, {
            header,
            width: 'auto',
            height: 'auto',
            contentStyle: { overflow: 'auto' },
            baseZIndex: 10000,
            data: { groups: event?.rowData, event: event?.action },
            maximizable: true,
            closable: true
        });

        this.ref.onClose.subscribe(() => {
            this.ref?.destroy();
            this.reloadTable();
        });
    }

    getRolesComboBox(): void {
        const request: any = {
            realm_id: environment.keycloak.realm,
            page: 0,
            size: 2147483647,
            sort: 'id',
            direction: 'ASC'
        };
        this.roleService.get(request).subscribe({
            next: (value) => {
                const roles = value['content'];
                this.roleList = roles.map((role) => ({
                    label: role.roleName,
                    value: role.roleName
                }));
            }
        });
    }
}
