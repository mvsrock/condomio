import { CommonModule } from '@angular/common';
import { Component, OnDestroy, OnInit, Optional } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { InputText } from 'primeng/inputtext';
import { ReusableTableComponent } from '../../../common/reusable-table/reusable-table.component';
import { RxFormBuilder, RxFormGroup } from '@rxweb/reactive-form-validators';
import { UserRequestTable } from './model/request/user-request';
import { UserService } from './services/user-service';
import { LazyLoadWithPageEvent } from '../../../common/reusable-table/LazyLoadWithPageEvent';
import { environment } from '../../../../environments/environment.development';
import { UserCreateDialogComponent } from './user-create-dialog-component/user-create-dialog-component.component';
import { ExposeControlDirective } from '../../../common/expose-control-directive';
import { InputFormControlComponent } from '../../../common/input-form-control';
import { ConfirmationService, MessageService } from 'primeng/api';
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';
import { SelectModule } from 'primeng/select';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { GroupsService } from '../groups/services/groups.service';
import * as _ from 'lodash';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

@Component({
    selector: 'app-users',
    imports: [FormsModule, ReusableTableComponent, ReactiveFormsModule, InputText, ButtonModule, InputFormControlComponent, ExposeControlDirective, CommonModule, SelectModule, ConfirmDialogModule, TranslateModule],
    providers: [DialogService, ConfirmationService],
    templateUrl: './users.component.html',
    styleUrl: './users.component.scss'
})
export class UsersComponent implements OnInit, OnDestroy {
    userFormGroup!: RxFormGroup;
    sizePage = 10;
    distributionCompany: any = [];
    groups: { label: string; name: string }[] = [];
    user = new UserRequestTable();
    item: any;
    totalRecords = 0;
    loading = false;
    page = 0;

    tableColumns: any[] = [];
    registeredUserActions: any[] = [];

    sort = 'email';
    direction = 1;
    directionDB: string = this.direction == 1 ? 'ASC' : 'DESC';

    private langSub?: Subscription;
    totalPage: number = 0;

    constructor(
        private formBuilder: RxFormBuilder,
        private userService: UserService,
        public dialogService: DialogService,
        @Optional() public ref: DynamicDialogRef,
        private messageService: MessageService,
        private confirmationService: ConfirmationService,
        private groupService: GroupsService,
        private translate: TranslateService
    ) {}

    ngOnInit(): void {
        // combobox dati
        const request: any = {
            realm_id: environment.keycloak.realm,
            page: 0,
            size: 2147483647,
            sort: 'groupID',
            direction: 'ASC'
        };
        this.groupService.get(request).subscribe({
            next: (item) => {
                this.groups = item['content']
                    .filter((items) => items.groupName)
                    .map((items) => ({
                        label: items.groupPath ? items.groupName! + '/' + items.groupPath : items.groupName!,
                        name: items.groupPath ? items.groupName! + '/' + items.groupPath : items.groupName!
                    }));

                this.distributionCompany = [
                    ...new Map(item['content'].filter((items) => items.distributionCompanyID).map((items) => [items.distributionCompanyID!, { id: items.distributionCompanyID!, name: items.distributionCompanyName }])).values()
                ];
            }
        });

        Object.setPrototypeOf(this.user, UserRequestTable.prototype);
        this.userFormGroup = this.formBuilder.formGroup(this.user) as RxFormGroup;

        // costruisci testi i18n all’avvio
        this.buildTableColumns();
        this.buildActions();

        // ricostruisci testi su cambio lingua
        this.langSub = this.translate.onLangChange.subscribe(() => {
            this.buildTableColumns();
            this.buildActions();
        });

        this.loading = true;
        this.reloadTable();
    }

    ngOnDestroy(): void {
        this.langSub?.unsubscribe();
    }

    private buildTableColumns(): void {
        this.tableColumns = [
            { field: 'email', header: this.translate.instant('pages.user.table.header_email'), sortField: 'email' },
            { field: 'firstName', header: this.translate.instant('pages.user.table.header_first_name'), sortField: 'firstName' },
            { field: 'lastName', header: this.translate.instant('pages.user.table.header_last_name'), sortField: 'lastName' },
            { field: 'username', header: this.translate.instant('pages.user.table.header_username'), sortField: 'username' },
            { field: 'groupName', header: this.translate.instant('pages.user.table.header_group'), sortField: 'groupName' },
            { field: 'identityProvider', header: this.translate.instant('pages.user.table.header_provider'), sortField: 'identityProvider' },
            { field: 'distributionCompany', header: this.translate.instant('pages.user.table.header_company'), sortField: 'distributionCompany' },
            { field: 'enabled', header: this.translate.instant('pages.user.table.header_enabled'), sortField: 'enabled' }
        ];
    }

    private buildActions(): void {
        this.registeredUserActions = [
            { icon: 'pi pi-plus', tooltip: this.translate.instant('pages.user.actions.add_company'), eventName: 'add' },
            { icon: 'pi pi-eye', tooltip: this.translate.instant('common.view'), eventName: 'view' },
            { icon: 'pi pi-pencil', tooltip: this.translate.instant('common.edit'), eventName: 'edit' },
            { icon: 'pi pi-trash', tooltip: this.translate.instant('common.delete'), eventName: 'delete', styleClass: 'p-button-danger p-button-sm' },
            { icon: 'pi pi-ban', tooltip: this.translate.instant('pages.user.actions.block'), eventName: 'block', styleClass: 'p-button-danger p-button-sm' },
            { icon: 'pi pi-sign-out', tooltip: this.translate.instant('pages.user.actions.remove_group'), eventName: 'deleteGroup', styleClass: 'p-button-danger p-button-sm' }
        ];
    }

    submit(): void {
        this.reloadTable();
    }

    handleLazyLoad(event: LazyLoadWithPageEvent) {
        this.sort = event.sortField as string;
        this.directionDB = event.sortOrder == 1 ? 'ASC' : 'DESC';
        this.page = event.currentPage;
        this.sizePage = event.rows as number;
        this.reloadTable();
    }

    reloadTable() {
        this.loading = true;
        const filterss = this.userFormGroup.value;
        const request: any = {
            ...filterss,
            realm_id: environment.keycloak.realm,
            page: this.page,
            size: this.sizePage,
            sort: this.sort,
            direction: this.directionDB
        };
        this.userService.getUsers(request).subscribe({
            next: (items) => {
                this.item = items['content'];
                this.totalRecords = items['totalElements'];
                this.sizePage = items['pageSize'];
                this.page = items['pageNumber'];
                this.totalPage = items['totalPages'];
                this.loading = false;
            },
            error: (err) => console.error('Errore nella chiamata menu:', err)
        });
    }

    shouldShowActions = (row: any): boolean => row.enabled;

    reset() {
        this.userFormGroup.reset();
        this.reloadTable();
    }

    onAddUser() {
        this.ref = this.dialogService.open(UserCreateDialogComponent, {
            header: this.translate.instant('pages.user.dialog.create_user_header'),
            width: '500px',
            height: '500px',
            contentStyle: { overflow: 'auto' },
            baseZIndex: 10000,
            maximizable: true,
            closable: true
        });
        this.ref.onClose.subscribe(() => this.reloadTable());
    }

    handleAction(event: { action: string; rowData: any }) {
        switch (event.action) {
            case 'edit': {
                const _user = _.cloneDeep(event.rowData);
                this.ref = this.dialogService.open(UserCreateDialogComponent, {
                    header: this.translate.instant('pages.user.dialog.edit_user_header'),
                    width: '500px',
                    height: '500px',
                    contentStyle: { overflow: 'auto' },
                    baseZIndex: 10000,
                    data: { users: _user, event: event.action },
                    maximizable: true,
                    closable: true
                });
                this.ref.onClose.subscribe(() => {
                    this.ref?.destroy();
                    this.reloadTable();
                });
                break;
            }

            case 'add': {
                const _user = _.cloneDeep(event.rowData);
                this.ref = this.dialogService.open(UserCreateDialogComponent, {
                    header: this.translate.instant('pages.user.dialog.add_company_header'),
                    width: '500px',
                    height: '500px',
                    contentStyle: { overflow: 'auto' },
                    baseZIndex: 10000,
                    data: { users: _user, event: event.action },
                    maximizable: true,
                    closable: true
                });
                this.ref.onClose.subscribe(() => {
                    this.ref?.destroy();
                    this.reloadTable();
                });
                break;
            }

            case 'deleteGroup': {
                const username = event.rowData?.username ?? '';
                const groupName = event.rowData?.groupName ?? '';
                const company = event.rowData?.distributionCompany ?? '';
                this.confirmationService.confirm({
                    message: this.translate.instant('pages.user.confirm.delete_group_message', { username, groupName, company }),
                    header: this.translate.instant('pages.user.confirm.delete_group_header', { username, groupName }),
                    icon: 'pi pi-exclamation-triangle',
                    acceptLabel: this.translate.instant('common.accept'),
                    rejectLabel: this.translate.instant('common.reject'),
                    accept: () => {
                        this.userService.deleteUserFromCompany(event.rowData?.userId, event.rowData?.groupId).subscribe({
                            next: () => {
                                this.messageService.add({
                                    severity: 'success',
                                    summary: this.translate.instant('pages.user.toast.success_updated'),
                                    detail: this.translate.instant('pages.user.toast.user_removed_from_group_detail')
                                });
                                this.reloadTable();
                            },
                            error: () => {
                                this.messageService.add({
                                    severity: 'error',
                                    summary: this.translate.instant('pages.user.toast.error_summary'),
                                    detail: this.translate.instant('pages.user.toast.delete_user_from_group_error_detail')
                                });
                            }
                        });
                    }
                });
                break;
            }

            case 'delete': {
                const username = event.rowData?.username ?? '';
                this.confirmationService.confirm({
                    message: this.translate.instant('pages.user.confirm.delete_message', { username }),
                    header: this.translate.instant('pages.user.confirm.delete_header', { username }),
                    icon: 'pi pi-exclamation-triangle',
                    acceptLabel: this.translate.instant('common.accept'),
                    rejectLabel: this.translate.instant('common.reject'),
                    accept: () => {
                        this.userService.delete(event.rowData?.userId).subscribe({
                            next: () => {
                                this.messageService.add({
                                    severity: 'success',
                                    summary: this.translate.instant('pages.user.toast.success_updated'),
                                    detail: this.translate.instant('pages.user.toast.user_deleted_detail')
                                });
                                this.reloadTable();
                            },
                            error: () => {
                                this.messageService.add({
                                    severity: 'error',
                                    summary: this.translate.instant('pages.user.toast.error_summary'),
                                    detail: this.translate.instant('pages.user.toast.delete_user_error_detail')
                                });
                            }
                        });
                    }
                });
                break;
            }

            case 'view': {
                this.ref = this.dialogService.open(UserCreateDialogComponent, {
                    header: this.translate.instant('pages.user.dialog.view_user_header'),
                    width: '500px',
                    height: '500px',
                    contentStyle: { overflow: 'auto' },
                    baseZIndex: 10000,
                    data: { users: event.rowData, event: event.action },
                    maximizable: true,
                    closable: true
                });
                this.ref.onClose.subscribe(() => {
                    this.ref?.destroy();
                    this.reloadTable();
                });
                break;
            }

            case 'block': {
                this.confirmationService.confirm({
                    message: this.translate.instant('pages.user.confirm.block_message'),
                    header: this.translate.instant('pages.user.confirm.block_header'),
                    icon: 'pi pi-exclamation-triangle',
                    acceptLabel: this.translate.instant('common.accept'),
                    rejectLabel: this.translate.instant('common.reject'),
                    accept: () => {
                        this.userService.disable(event.rowData?.userId).subscribe({
                            next: () => {
                                this.messageService.add({
                                    severity: 'success',
                                    summary: this.translate.instant('pages.user.toast.user_blocked_summary'),
                                    detail: this.translate.instant('pages.user.toast.user_blocked_detail')
                                });
                                this.reloadTable();
                            },
                            error: () => {
                                this.messageService.add({
                                    severity: 'error',
                                    summary: this.translate.instant('pages.user.toast.error_summary'),
                                    detail: this.translate.instant('pages.user.toast.block_user_error_detail')
                                });
                            }
                        });
                    }
                });
                break;
            }

            default: {
                this.reloadTable();
                break;
            }
        }
    }

    handleUserCreated(_: any) {
        this.reloadTable();
    }
    //singolo campo da vedere
    /* canClickCell = ({ column, rowData }: any) => {
        if (column.field === 'email' && rowData!.enabled === true) {
            return [
                {
                    id: 'email',
                    icon: 'pi pi-envelope',
                    label: rowData.email
                }
            ];
        }
        return false;
    };*/

    //stesso campo con piu stati
    canClickCell = ({ column, rowData }: any) => {
        if (column.field === 'email' && rowData!.enabled === true) {
            return [
                {
                    id: 'email',
                    icon: 'pi pi-envelope',
                    label: rowData.email
                }
            ];
        } else if (column.field == 'email' && !rowData?.enabled) {
            return [
                {
                    id: 'email',
                    icon: 'pi pi-times-circle',
                    // label: rowData.email,
                    title: this.translate.instant('pages.user.toast.user_blocked_summary'),
                    clickable: false
                }
            ];
        }
        return false;
    };
    //piu campi da cliccare e piu stati
    /* canClickCell = ({ column, rowData }: any) => {
        const targets = [];
        if (column.field == 'email' && rowData?.enabled) {
            targets.push({
                id: 'email',
                icon: 'pi pi-envelope',
                //   label: rowData.email,
                clickable: true
            });
        } else if (column.field == 'email' && !rowData?.enabled) {
            targets.push({
                id: 'email',
                icon: 'pi pi-times-circle',
                // label: rowData.email,
                title: this.translate.instant('pages.user.toast.user_blocked_summary'),
                clickable: false
            });
        }

        if (column.field == 'distributionCompany' && rowData?.distributionCompany && rowData?.enabled) {
            targets.push({
                id: 'company',
                icon: 'pi pi-building',
                label: rowData.distributionCompany,
                clickable: true,
                value: rowData.distributionCompany
            });
        }else if (column.field == 'distributionCompany' && rowData?.distributionCompany && !rowData?.enabled){
            targets.push({
                id: 'company',
                icon: 'pi pi-building',
                label: rowData.distributionCompany,
                title: rowData.distributionCompany,
                clickable: false,
                value: rowData.distributionCompany
            });
        }

        return targets;
    };*/

    handleCell(ev: any) {
        console.log('cliccato ', ev);
        // eventuale gestione click cella
    }

    registeredUserVisibilityFn = (action: string, row: any): boolean => {
        if (!row.enabled) return action === 'view' || action === 'edit';
        if (!row.groupId) return action === 'view' || action === 'edit' || action === 'delete';
        return true;
    };
}
