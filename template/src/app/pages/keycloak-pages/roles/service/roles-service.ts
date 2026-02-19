import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../../environments/environment.development';
import { PageResponse } from '../../../../common/page-response/page-response';
import { KeycloakRoleGroupRequest, RoleCreated, RoleRequest } from '../models/roleRequest';
import { QueryStringService } from '../../../../services/query-string-service';

@Injectable({
    providedIn: 'root'
})
export class RolesService {
    constructor(
        private http: HttpClient,
        private qs: QueryStringService
    ) {}

    get(request: RoleRequest): Observable<PageResponse<KeycloakRoleGroupRequest>> {
        const queryString = this.qs.toQueryString(request);
        const url = `${environment.roles.get}?${queryString}`;
        return this.http.get<PageResponse<KeycloakRoleGroupRequest>>(url);
    }

    created(requests: RoleCreated): Observable<any> {
        return this.http.post(environment.roles.created, requests);
    }
    update(request: RoleCreated, id: string): Observable<any> {
        return this.http.put(environment.roles.update + id, request);
    }
    deleted(roleId: string) {
        const url = environment.roles.deleted(roleId);
        return this.http.delete(url, {});
    }
}
