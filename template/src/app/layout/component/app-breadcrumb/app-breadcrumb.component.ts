import { Component, OnInit } from '@angular/core';
import { BreadcrumbService } from './service/breadcrumb.service';
import { BreadcrumbModule } from 'primeng/breadcrumb';
import { MenuItem } from 'primeng/api';
import { map, Observable } from 'rxjs';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-breadcrumb',
    standalone: true,
    imports: [BreadcrumbModule, CommonModule],
    templateUrl: './app-breadcrumb.component.html',
    styleUrls: ['./app-breadcrumb.component.scss']
})
export class AppBreadcrumbComponent implements OnInit {
    items$!: Observable<MenuItem[]>;

    get breadcrumbItems(): MenuItem[] | undefined {
        let val: MenuItem[] | null = null;
        this.items$.subscribe((items) => (val = items));
        return val ?? undefined;
    }

    constructor(public breadcrumbService: BreadcrumbService) {}

    ngOnInit() {
        this.items$ = this.breadcrumbService.items$.pipe(map((items) => items ?? []));
    }
}
