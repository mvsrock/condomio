import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { MenuItemDto } from '../model/MenuItemDto';
import { Observable } from 'rxjs';
import { environment } from '../../../../../environments/environment.development';
import { PageResponse } from '../../../../common/page-response/page-response';
import { QueryStringService } from '../../../../services/query-string-service';

@Injectable({
    providedIn: 'root'
})
export class MenuService {
    constructor(
        private http: HttpClient,
        private qs: QueryStringService
    ) {}

    get(request: any): Observable<PageResponse<MenuItemDto>> {
        const queryString = this.qs.toQueryString(request);
        const url = `${environment.menus.get}?${queryString}`;
        return this.http.get<PageResponse<MenuItemDto>>(url);
    }

    update(menu: MenuItemDto): Observable<void> {
        return this.http.put<void>(environment.menus.update + menu.id, menu);
    }

    create(menu: MenuItemDto): Observable<MenuItemDto> {
        return this.http.post<MenuItemDto>(environment.menus.get, menu);
    }

    delete(id: number, deleteBranch = false): Observable<void> {
        return this.http.delete<void>(environment.menus.delete + id + '?deleteBranch=' + deleteBranch);
    }
}
