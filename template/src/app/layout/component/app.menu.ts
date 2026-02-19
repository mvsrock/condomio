import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { MenuItem } from 'primeng/api';

import { AppMenuitem } from './app.menuitem';
import { MenuItemPrimeNG, MenuService, RawMenuItem } from './services/menu/menu-service';
import { BreadcrumbService } from './app-breadcrumb/service/breadcrumb.service';
import { TranslateModule, TranslateService } from '@ngx-translate/core';

@Component({
    selector: 'app-menu',
    standalone: true,
    imports: [CommonModule, AppMenuitem, RouterModule, TranslateModule],
    template: `<ul class="layout-menu">
        <ng-container *ngFor="let item of model; let i = index">
            <li app-menuitem *ngIf="!item.separator" [item]="item" [index]="i" [root]="true"></li>
            <li *ngIf="item.separator" class="menu-separator"></li>
        </ng-container>
    </ul> `
})
export class AppMenu {
    constructor(
        private menuService: MenuService,
        private breadcrumbService: BreadcrumbService,
        private translate: TranslateService
    ) {}

    model: MenuItem[] = [];

    ngOnInit() {
        this.menuService.getMenuItemsByRoles().subscribe({
            next: (items) => {
                this.model = buildTree(items, this.translate);
                this.breadcrumbService.setMenuModel(this.model);
            },
            error: (err) => console.error('Errore nella chiamata menu:', err)
        });
        /*  this.model = [
              {
                  label: 'Home',
                  items: [{ label: 'Dashboard', icon: 'pi pi-fw pi-home', routerLink: ['/'] }]
              },
              {
                  label: 'UI Components',
                  items: [
                      { label: 'Form Layout', icon: 'pi pi-fw pi-id-card', routerLink: ['/uikit/formlayout'] },
                      { label: 'Input', icon: 'pi pi-fw pi-check-square', routerLink: ['/uikit/input'] },
                      { label: 'Button', icon: 'pi pi-fw pi-mobile', class: 'rotated-icon', routerLink: ['/uikit/button'] },
                      { label: 'Table', icon: 'pi pi-fw pi-table', routerLink: ['/uikit/table'] },
                      { label: 'List', icon: 'pi pi-fw pi-list', routerLink: ['/uikit/list'] },
                      { label: 'Tree', icon: 'pi pi-fw pi-share-alt', routerLink: ['/uikit/tree'] },
                      { label: 'Panel', icon: 'pi pi-fw pi-tablet', routerLink: ['/uikit/panel'] },
                      { label: 'Overlay', icon: 'pi pi-fw pi-clone', routerLink: ['/uikit/overlay'] },
                      { label: 'Media', icon: 'pi pi-fw pi-image', routerLink: ['/uikit/media'] },
                      { label: 'Menu', icon: 'pi pi-fw pi-bars', routerLink: ['/uikit/menu'] },
                      { label: 'Message', icon: 'pi pi-fw pi-comment', routerLink: ['/uikit/message'] },
                      { label: 'File', icon: 'pi pi-fw pi-file', routerLink: ['/uikit/file'] },
                      { label: 'Chart', icon: 'pi pi-fw pi-chart-bar', routerLink: ['/uikit/charts'] },
                      { label: 'Timeline', icon: 'pi pi-fw pi-calendar', routerLink: ['/uikit/timeline'] },
                      { label: 'Misc', icon: 'pi pi-fw pi-circle', routerLink: ['/uikit/misc'] }
                  ]
              },
              {
                  label: 'Pages',
                  icon: 'pi pi-fw pi-briefcase',
                  routerLink: ['/pages'],
                  items: [
                      {
                          label: 'Landing',
                          icon: 'pi pi-fw pi-globe',
                          routerLink: ['/landing']
                      },
                      {
                          label: 'Auth',
                          icon: 'pi pi-fw pi-user',
                          items: [
                              {
                                  label: 'Login',
                                  icon: 'pi pi-fw pi-sign-in',
                                  routerLink: ['/auth/login']
                              },
                              {
                                  label: 'Error',
                                  icon: 'pi pi-fw pi-times-circle',
                                  routerLink: ['/auth/error']
                              },
                              {
                                  label: 'Access Denied',
                                  icon: 'pi pi-fw pi-lock',
                                  routerLink: ['/auth/access']
                              }
                          ]
                      },
                      {
                          label: 'Crud',
                          icon: 'pi pi-fw pi-pencil',
                          routerLink: ['/pages/crud']
                      },
                      {
                          label: 'Not Found',
                          icon: 'pi pi-fw pi-exclamation-circle',
                          routerLink: ['/pages/notfound']
                      },
                      {
                          label: 'Empty',
                          icon: 'pi pi-fw pi-circle-off',
                          routerLink: ['/pages/empty']
                      }
                  ]
              },
              {
                  label: 'Hierarchy',
                  items: [
                      {
                          label: 'Submenu 1',
                          icon: 'pi pi-fw pi-bookmark',
                          items: [
                              {
                                  label: 'Submenu 1.1',
                                  icon: 'pi pi-fw pi-bookmark',
                                  items: [
                                      { label: 'Submenu 1.1.1', icon: 'pi pi-fw pi-bookmark' },
                                      { label: 'Submenu 1.1.2', icon: 'pi pi-fw pi-bookmark' },
                                      { label: 'Submenu 1.1.3', icon: 'pi pi-fw pi-bookmark' }
                                  ]
                              },
                              {
                                  label: 'Submenu 1.2',
                                  icon: 'pi pi-fw pi-bookmark',
                                  items: [{ label: 'Submenu 1.2.1', icon: 'pi pi-fw pi-bookmark' }]
                              }
                          ]
                      },
                      {
                          label: 'Submenu 2',
                          icon: 'pi pi-fw pi-bookmark',
                          items: [
                              {
                                  label: 'Submenu 2.1',
                                  icon: 'pi pi-fw pi-bookmark',
                                  items: [
                                      { label: 'Submenu 2.1.1', icon: 'pi pi-fw pi-bookmark' },
                                      { label: 'Submenu 2.1.2', icon: 'pi pi-fw pi-bookmark' }
                                  ]
                              },
                              {
                                  label: 'Submenu 2.2',
                                  icon: 'pi pi-fw pi-bookmark',
                                  items: [{ label: 'Submenu 2.2.1', icon: 'pi pi-fw pi-bookmark' }]
                              }
                          ]
                      }
                  ]
              },
              {
                  label: 'Get Started',
                  items: [
                      {
                          label: 'Documentation',
                          icon: 'pi pi-fw pi-book',
                          routerLink: ['/documentation']
                      },
                      {
                          label: 'View Source',
                          icon: 'pi pi-fw pi-github',
                          url: 'https://github.com/primefaces/sakai-ng',
                          target: '_blank'
                      }
                  ]
              }
          ];*/

        function buildTree(flatData: RawMenuItem[], t: TranslateService): MenuItemPrimeNG[] {
            const idMap = new Map<number, MenuItemPrimeNG & { parentId?: number }>();
            const roots: MenuItemPrimeNG[] = [];

            flatData.forEach((item) => {
                // 1) Garantisco una chiave stringa per la traduzione
                const labelKey: string = item.label ?? 'sidebar.untitled'; // <-- metti una chiave fallback che esiste nel tuo i18n
                const label: string = t.instant(labelKey) as string;

                idMap.set(item.id, {
                    label,
                    icon: item.icon ?? 'pi pi-circle',
                    // 2) routerLink è opzionale: se c'è uri lo metto come array (PrimeNG lo supporta)
                    routerLink: item.uri ? [item.uri] : undefined,
                    items: [],
                    // 3) accesso opzionale al parent id
                    parentId: item.parent?.id
                });
            });

            idMap.forEach((item, id) => {
                if (item.parentId !== undefined) {
                    const parent = idMap.get(item.parentId);
                    if (parent) {
                        (parent.items ??= []).push(item);
                    } else {
                        roots.push(item);
                    }
                } else {
                    roots.push(item);
                }
                delete item.parentId;
            });

            function cleanEmptyItems(node: MenuItemPrimeNG) {
                if (node.items && node.items.length === 0) {
                    delete node.items;
                } else if (node.items) {
                    node.items.forEach(cleanEmptyItems);
                }
            }
            roots.forEach(cleanEmptyItems);

            return roots;
        }
    }
}
