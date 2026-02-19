import { Injectable } from '@angular/core';
import { NavigationEnd, Router } from '@angular/router';
import { MenuItem } from 'primeng/api';
import { BehaviorSubject, filter } from 'rxjs';
import { MenuItemPrimeNG } from '../../services/menu/menu-service';

@Injectable({ providedIn: 'root' })
export class BreadcrumbService {
    private menuModel: MenuItemPrimeNG[] = [];
    private itemsSubject = new BehaviorSubject<MenuItem[]>([]);
    items$ = this.itemsSubject.asObservable();

    constructor(private router: Router) {
        this.router.events.pipe(filter((e) => e instanceof NavigationEnd)).subscribe(() => this.updateBreadcrumb());
    }

    setMenuModel(model: MenuItemPrimeNG[]) {
        this.menuModel = model;
        this.updateBreadcrumb();
    }

    private updateBreadcrumb() {
        const url = this.router.url.split('#')[0];
        const path = this.findPath(this.menuModel, url);
        this.itemsSubject.next(
            path.map((item) => ({
                label: item.label,
                icon: item.icon,
                routerLink: item.routerLink
            }))
        );
    }

    private findPath(menu: MenuItemPrimeNG[], url: string, parents: MenuItemPrimeNG[] = []): MenuItemPrimeNG[] {
        for (let item of menu) {
            if (item.routerLink && item.routerLink[0] === url) {
                return [...parents, item];
            }
            if (item.items) {
                const childPath = this.findPath(item.items, url, [...parents, item]);
                if (childPath.length) {
                    return childPath;
                }
            }
        }
        return [];
    }
}
