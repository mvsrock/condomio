import { Component, OnDestroy, OnInit, Optional } from '@angular/core';
import { MenuService } from './service/menu-service';
import { MenuItemDto } from './model/MenuItemDto';
import { LazyLoadWithPageEvent, ReusableTableComponent } from '../../../common/reusable-table/reusable-table.component';
import { MenuItemRequest } from './model/menu-request';
import { RxFormBuilder, RxFormGroup } from '@rxweb/reactive-form-validators';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { InputText } from 'primeng/inputtext';
import { SelectModule } from 'primeng/select';
import { ExposeControlDirective } from '../../../common/expose-control-directive';
import { InputFormControlComponent } from '../../../common/input-form-control';
import { RolesService } from '../../keycloak-pages/roles/service/roles-service';
import { environment } from '../../../../environments/environment.development';
import { DialogService, DynamicDialogRef } from 'primeng/dynamicdialog';
import { MenuDialogComponent } from './menu-dialog/menu-dialog.component';
import { ConfirmationService, MessageService } from 'primeng/api';
import _ from 'lodash';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { Subscription } from 'rxjs';

import { DialogModule } from 'primeng/dialog';
import { ToggleSwitchModule } from 'primeng/toggleswitch';

@Component({
    selector: 'app-menu',
    imports: [ReusableTableComponent, FormsModule, ReactiveFormsModule, InputText, ButtonModule, InputFormControlComponent, ExposeControlDirective, CommonModule, SelectModule, ConfirmDialogModule, TranslateModule, ToggleSwitchModule, DialogModule],
    providers: [DialogService, ConfirmationService],
    templateUrl: './menu.component.html',
    styleUrl: './menu.component.scss'
})
export class MenuComponent implements OnInit, OnDestroy {
    roleList: any = [];
    menuRequest: MenuItemRequest = new MenuItemRequest();
    menuFormGroup!: RxFormGroup;
    sizePage = 10;
    totalRecords = 0;
    loading = false;
    page = 0;
    sort = 'label';
    direction = 1;
    directionDB: string = this.direction == 1 ? 'ASC' : 'DESC';

    tableColumns: any[] = [];
    actions: any[] = [];

    private langSub?: Subscription;

    menuTable: MenuItemDto[] = [];

    showDeleteDialog: boolean = false;
    deleteBranch: boolean = false;
    deleteMeasure: boolean = false;
    selectedItemId!: number;
    deleteLabel = '';
    totalPage: number = 0;
    constructor(
        private menuService: MenuService,
        private formBuilder: RxFormBuilder,
        private roleService: RolesService,
        public dialogService: DialogService,
        private messageService: MessageService,
        private translate: TranslateService,
        @Optional() public ref: DynamicDialogRef,
        private confirmationService: ConfirmationService
    ) {}

    ngOnInit(): void {
        Object.setPrototypeOf(this.menuRequest, MenuItemRequest.prototype);
        this.menuFormGroup = this.formBuilder.formGroup(this.menuRequest) as RxFormGroup;

        this.buildTableColumns();
        this.buildActions();

        this.langSub = this.translate.onLangChange.subscribe(() => {
            this.buildTableColumns();
            this.buildActions();
        });

        this.getRolesComboBox();
        this.loading = true;
        this.reloadTable();
    }

    ngOnDestroy(): void {
        this.langSub?.unsubscribe();
    }

    private buildTableColumns(): void {
        this.tableColumns = [
            { field: 'label', header: this.translate.instant('pages.menu.table.header_label'), sortField: 'label' },
            { field: 'icon', header: this.translate.instant('pages.menu.table.header_icon'), sortField: 'icon' },
            { field: 'description', header: this.translate.instant('pages.menu.table.header_description'), sortField: 'description' },
            { field: 'uri', header: this.translate.instant('pages.menu.table.header_url'), sortField: 'uri' },
            { field: 'parent', header: this.translate.instant('pages.menu.table.header_parent'), sortField: 'parent' },
            { field: 'visible', header: this.translate.instant('pages.menu.table.header_is_visible'), sortField: 'visible' },
            { field: 'visualOrder', header: this.translate.instant('pages.menu.table.header_display_order'), sortField: 'visualOrder' },
            { field: 'roleName', header: this.translate.instant('pages.menu.table.header_role'), sortField: 'role.name' }
        ];
    }

    private buildActions(): void {
        this.actions = [
            { icon: 'pi pi-eye', tooltip: this.translate.instant('common.view'), eventName: 'view' },
            { icon: 'pi pi-pencil', tooltip: this.translate.instant('common.edit'), eventName: 'edit' },
            { icon: 'pi pi-trash', tooltip: this.translate.instant('common.delete'), eventName: 'delete', styleClass: 'p-button-danger p-button-sm' }
        ];
    }

    reloadTable() {
        this.loading = true;

        const filters: MenuItemRequest = this.menuFormGroup.value;
        const request: any = {
            ...filters,
            page: this.page,
            size: this.sizePage,
            sort: this.sort,
            direction: this.directionDB
        };

        this.menuService.get(request).subscribe({
            next: (items) => {
                this.menuTable = items['content'];
                this.totalRecords = items['totalElements'];
                this.sizePage = items['pageSize'];
                this.page = items['pageNumber'];
                this.totalPage = items['totalPages'];
                this.loading = false;
            },
            error: (err) => console.error('Errore nella chiamata menu:', err)
        });
    }

    handleLazyLoad(event: LazyLoadWithPageEvent) {
        this.sort = event.sortField as string;
        this.directionDB = event.sortOrder == 1 ? 'ASC' : 'DESC';
        this.page = event.currentPage;
        this.sizePage = event.rows as number;
        this.reloadTable();
    }

    handleAction(event: any): void {
        switch (event.action) {
            case 'edit': {
                this.openDialog(this.translate.instant('pages.menu.dialog.edit'), event);
                break;
            }
            case 'delete': {
                const label = this.translate.instant(event.rowData?.label) ?? '';
                this.selectedItemId = event.rowData?.id;
                this.deleteLabel = event.rowData?.label ?? '';

                this.deleteBranch = false;
                this.deleteMeasure = true;

                this.showDeleteDialog = true;

                break;
            }
            case 'view': {
                this.openDialog(this.translate.instant('pages.menu.dialog.view'), event);
                break;
            }
            default: {
                this.reloadTable();
                break;
            }
        }
    }

    confirmDelete(): void {
        if (!this.selectedItemId) return;

        this.menuService.delete(this.selectedItemId, this.deleteBranch).subscribe({
            next: () => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('pages.menu.toast.delete_success_summary'),
                    detail: this.translate.instant('pages.menu.toast.delete_success_detail')
                });
                this.reloadTable();
            },
            error: (err) => {
                console.error('Errore nella cancellazione:', err);
                this.messageService.add({
                    severity: 'error',
                    summary: this.translate.instant('pages.menu.toast.error_summary'),
                    detail: this.translate.instant('pages.menu.toast.delete_error_detail')
                });
            },
            complete: () => {
                this.showDeleteDialog = false;
            }
        });
    }

    create() {
        this.openDialog(this.translate.instant('pages.menu.dialog.create'), { rowData: new MenuItemDto(), action: 'create' });
    }

    private openDialog(header: string, event?: any): void {
        const _menu = _.cloneDeep(event?.rowData);
        this.ref = this.dialogService.open(MenuDialogComponent, {
            header,
            width: '700px',
            height: '700px',
            contentStyle: { overflow: 'auto' },
            baseZIndex: 10000,
            data: {
                menu: _menu,
                event: event?.action
            },
            maximizable: true,
            closable: true
        });

        this.ref.onClose.subscribe((result: any) => {
            this.ref?.destroy();
            this.reloadTable();
        });
    }

    getRolesComboBox() {
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
                    id: role.roleId
                }));
            }
        });
    }

    submit() {
        this.reloadTable();
    }

    reset() {
        this.menuFormGroup.reset();
        this.reloadTable();
    }
}
