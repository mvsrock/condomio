import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from '../../../../../environments/environment.development';
import { PageResponse } from '../../../../common/page-response/page-response';
import { GroupsDetail, GroupSerch } from '../models/groups-created';
import { SubGroupObject } from '../group-dialog-create-subgroup/subGroup';
import { QueryStringService } from '../../../../services/query-string-service';

@Injectable({
    providedIn: 'root'
})
export class GroupsService {
    constructor(
        private http: HttpClient,
        private qs: QueryStringService
    ) {}

    get(request: any): Observable<PageResponse<GroupSerch>> {
        const queryString = this.qs.toQueryString(request);
        const url = `${environment.groups.get}?${queryString}`;
        return this.http.get<PageResponse<GroupSerch>>(url);
    }

    post(request: GroupsDetail): Observable<any> {
        request.realmId = environment.keycloak.realm;
        return this.http.post(environment.groups.created, request);
    }

    update(request: GroupsDetail, id: string): Observable<any> {
        request.realmId = environment.keycloak.realm;
        return this.http.put(environment.groups.update + id, request);
    }

    deleted(groupId: string): Observable<any> {
        const url = environment.groups.deleted(groupId);
        return this.http.delete<any>(url, {});
    }
    updateAttr(groupId: string, request: any): Observable<any> {
        const url = environment.groups.updateAttr(groupId);
        return this.http.put(url, request);
    }

    createSubGroup(request: SubGroupObject, groupId: string): Observable<any> {
        const url = environment.groups.createSubGroup(groupId);
        return this.http.post(url, request);
    }

    getGroupsAndSubGroupFromDistributionCommpanyID(distributionId: string): Observable<any> {
        const url = environment.groups.findSubGroupById(distributionId);
        return this.http.get(url);
    }
}
