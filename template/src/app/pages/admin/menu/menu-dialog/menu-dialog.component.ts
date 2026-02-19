import { CommonModule } from '@angular/common';
import { Component, OnInit, Optional } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
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
import { MenuItemDto } from '../model/MenuItemDto';
import { PRIME_ICONS } from '../model/prime-icon';
import { RolesService } from '../../../keycloak-pages/roles/service/roles-service';
import { environment } from '../../../../../environments/environment.development';
import { MenuService } from '../service/menu-service';
import { MessageService } from 'primeng/api';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-menu-dialog',
    imports: [FormsModule, ReactiveFormsModule, DialogModule, InputTextModule, PasswordModule, MultiSelectModule, ButtonModule, ExposeControlDirective, InputFormControlComponent, CardModule, CommonModule, SelectModule, TranslateModule],
    providers: [DialogService],
    templateUrl: './menu-dialog.component.html',
    styleUrl: './menu-dialog.component.scss'
})
export class MenuDialogComponent implements OnInit {
    menuFormGroup!: RxFormGroup;
    menu = new MenuItemDto();
    event: any;
    roleList: any = [];

    iconOptions = PRIME_ICONS.map((icon) => ({
        label: icon.replace('pi pi-', ''),
        value: icon
    }));

    selectorBoxVisible = [
        {
            label: 'Si',
            value: true
        },
        {
            label: 'No',
            value: false
        }
    ];
    parentList: { label: string; value: number }[] = [];
    constructor(
        private formBuilder: RxFormBuilder,
        public config: DynamicDialogConfig,
        public messageService: MessageService,
        @Optional() public ref: DynamicDialogRef,
        public dialogService: DialogService,
        private roleService: RolesService,
        private menuService: MenuService,
        private translate: TranslateService
    ) {}
    ngOnInit(): void {
        this.menu = this.config?.data?.menu;
        this.event = this.config?.data?.event;
        switch (this.event) {
            case 'view':
                this.prepareGroupForm(true);
                break;
            case 'edit':
                this.prepareGroupForm(false);
                break;
            case 'create':
                this.prepareGroupForm(false);
                break;
        }
    }

    getIconObj($event: any) {}
    close() {
        this.menuFormGroup.reset();
        this.ref.close();
    }
    update() {
        this.menuService.update(this.menuFormGroup.value as MenuItemDto).subscribe({
            next: (item) => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('pages.menu.toast.update_success_summary'),
                    detail: this.translate.instant('pages.menu.toast.update_success_detail')
                });
                this.close();
            },
            error: (error) => {
                console.log(error);
            }
        });
    }
    create() {
        this.menuService.create(this.menuFormGroup.value as MenuItemDto).subscribe({
            next: (item) => {
                this.messageService.add({
                    severity: 'success',
                    summary: this.translate.instant('pages.menu.toast.create_success_summary'),
                    detail: this.translate.instant('pages.menu.toast.create_success_detail')
                });
                this.close();
            },
            error: (error) => {
                console.log(error);
            }
        });
    }

    private prepareGroupForm(disableForm: boolean) {
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
                    value: role.roleId
                }));
                const selectedRoleName: string = this.menu.roleName ?? '';
                const matchingRole = roles.find((role) => role.roleName === selectedRoleName);
                const matchingId = matchingRole?.roleId ?? null;
                this.menuFormGroup.controls['roleId'].setValue(matchingId);
            }
        });

        this.menuService.get(request).subscribe({
            next: (value) => {
                const parents = value['content'];

                this.parentList = parents.map((parent) => ({
                    label: this.translate.instant(parent.label as string),
                    value: parent.id as number
                }));
                this.parentList = this.parentList.filter((parent) => parent.value !== this.menu.id);
                const selectedParentName: string = this.menu.parent ?? '';
                const matchingParent = parents.find((parent) => parent.label === selectedParentName);
                const matchingId = matchingParent?.id ?? null;
                this.menuFormGroup.controls['parent'].setValue(matchingId);
            }
        });

        Object.setPrototypeOf(this.menu, MenuItemDto.prototype);
        this.menuFormGroup = this.formBuilder.formGroup(this.menu) as RxFormGroup;

        if (disableForm) {
            this.menuFormGroup.disable();
        }
    }
}
