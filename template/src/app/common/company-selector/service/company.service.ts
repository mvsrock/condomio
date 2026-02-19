import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../../environments/environment.development';

export interface CompanyOption {
  description: string;
  id: string;
}

@Injectable({
  providedIn: 'root'
})
export class CompanyService {
  constructor(private http: HttpClient) {}

  getCompaniesByNames(name: string|null): Observable<CompanyOption[]> {
    if(name !=null){
    return this.http.get<CompanyOption[]>(environment.distribution_company.get+'/'+name);

    }else{
    return this.http.get<CompanyOption[]>(environment.distribution_company.get);

    }
  }
}
