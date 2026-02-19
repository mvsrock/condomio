import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../../../environments/environment.development';
import { PageResponse } from '../../../../common/page-response/page-response';
import { Injectable } from '@angular/core';
import { QueryStringService } from '../../../../services/query-string-service';
import { UserRequestTable } from '../model/request/user-request';
import { KeycloakUserGroupView } from '../model/request/user-model-created';
import { GroupsDetail } from '../../groups/models/groups-created';

@Injectable({ providedIn: 'root' })
export class UserService {
    constructor(
        private http: HttpClient,
        private qs: QueryStringService
    ) {}

    getUsers(request: UserRequestTable): Observable<PageResponse<KeycloakUserGroupView>> {
        const queryString = this.qs.toQueryString(request);
        const url = `${environment.users.get}?${queryString}`;
        return this.http.get<PageResponse<any>>(url);
    }

    createUser(request: KeycloakUserGroupView): Observable<any> {
        return this.http.post<any>(environment.users.create, request);
    }

    updateUser(request: KeycloakUserGroupView): Observable<void> {
        return this.http.put<void>(environment.users.update, request);
    }

    disable(userId: string): Observable<void> {
        const url = environment.users.disable(userId);
        return this.http.put<any>(url, {});
    }

    deleteUserFromCompany(idUser: string, groupId: string): Observable<void> {
        const url = environment.users.deleteUserFromCompany(idUser, groupId);
        return this.http.delete<any>(url, {});
    }
    delete(userId: string): Observable<void> {
        const url = environment.users.delete(userId);
        return this.http.delete<any>(url, {});
    }

    distributionNotIn(userId: string): Observable<GroupsDetail[]> {
        const url = environment.users.user_distribution_not_in(userId);
        return this.http.get<GroupsDetail[]>(url);
    }

    addUserToGroups(userId: string, payload: { groupIds: string[] }): Observable<void> {
        const url = environment.users.addUserToGroups(userId);
        return this.http.post<any>(url, payload);
    }
}
