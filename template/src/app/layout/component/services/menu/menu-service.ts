import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { map, Observable } from 'rxjs';
import { environment } from '../../../../../environments/environment.development';

export class RawMenuItem {
    id!: number;
    label?: string;
    icon?: string;
    uri?: string | null;
    parent?: { id: number } | null;
}

export class MenuItemPrimeNG {
    label?: string;
    icon?: string;
    routerLink?: string[];
    items?: MenuItemPrimeNG[];
}
@Injectable({
    providedIn: 'root'
})
export class MenuService {
    constructor(private http: HttpClient) {}

    getMenuItemsByRoles(): Observable<RawMenuItem[]> {
        return this.http.get<any[]>(environment.menus.getMenuItemsByRoles).pipe(map((items: any[]) => items.map((item) => this.mapToRawMenuItem(item))));
    }
    mapToRawMenuItem(data: any): RawMenuItem {
        return {
            id: data.id,
            label: data.label,
            icon: data.icon,
            uri: data.uri,
            parent: data.parent ? { id: data.parent.id } : null
        };
    }
}
