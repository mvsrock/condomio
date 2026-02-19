import { Component, EventEmitter, OnInit, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { jwtHelper } from '../../services/jwt_helper/jwt-helper';
import { CompanyOption, CompanyService } from './service/company.service';
import { SelectModule } from 'primeng/select';
import { TranslateModule } from '@ngx-translate/core';

interface CompanySelection {
    description?: string | null;
    id?: string | null;
}

@Component({
    selector: 'app-company-selector',
    standalone: true,
    imports: [CommonModule, FormsModule, SelectModule, TranslateModule],
    templateUrl: './company-selector.component.html',
    styleUrl: './company-selector.component.scss'
})
export class CompanySelectorComponent implements OnInit {
    companyOptions: CompanyOption[] = [];
    selectedCompany?: CompanySelection = {};
    loading = true;

    @Output() companyChange = new EventEmitter<CompanySelection>();
    piva: string | null = null;
    constructor(
        private jwtHelperService: jwtHelper,
        private companyService: CompanyService
    ) {}

    async ngOnInit(): Promise<void> {
        await this.loadCompaniesFromToken();
    }

    private async loadCompaniesFromToken(): Promise<void> {
        try {
            const token = await this.jwtHelperService.getToken();
            if (!token) {
                this.loading = false;
                return;
            }

            const decoded: any = this.jwtHelperService.decoderToken(token);
            const roles: string[] = decoded?.realm_access?.roles ?? [];
            const isAuthorityAdmin = Array.isArray(roles) && roles.includes('authority_admin');

            if (isAuthorityAdmin) {
                this.loadCompaniesFromApi();
                return;
            }

            let companies: string[] = [];
            const raw = decoded?.company_name;

            if (Array.isArray(raw)) {
                companies = raw;
            } else if (typeof raw === 'string') {
                companies = [raw];
            }

            companies = Array.from(new Set(companies.filter((x) => !!x)));

            const rawPiva = decoded?.piva;
            if (Array.isArray(rawPiva)) {
                this.piva = rawPiva[0] ?? null;
            } else if (typeof rawPiva === 'string') {
                this.piva = rawPiva;
            } else {
                this.piva = null;
            }
            this.companyOptions = companies.map((c) => ({
                description: c,
                id: this.piva!
            }));

            if (this.companyOptions.length === 1) {
                this.selectedCompany = {
                    description: this.companyOptions[0].description,
                    id: this.companyOptions[0].id
                };

                this.companyChange.emit({
                    description: this.selectedCompany.description ?? null,
                    id: this.selectedCompany.id ?? null
                });
            } else {
                this.loadCompaniesFromApi();
            }
        } catch (err) {
            console.error('Errore lettura company_name da token', err);
        } finally {
            this.loading = false;
        }
    }

    private async loadCompaniesFromApi(): Promise<void> {
        this.companyService.getCompaniesByNames(null).subscribe({
            next: (items) => {
                const list = items ?? [];

                const seen = new Set<string>();

                this.companyOptions = list.filter((elem) => {
                    if (!elem.id) {
                        return true;
                    }
                    if (seen.has(elem.id)) {
                        return false;
                    }
                    seen.add(elem.id);
                    return true;
                });
            }
        });
        this.companyChange.emit({
            description: null,
            id: null
        });
    }
    onSelect(value: any) {
        this.selectedCompany = value.value;
        this.companyChange.emit({
            description: this.selectedCompany?.description,
            id: this.selectedCompany?.id
        });
    }
}
