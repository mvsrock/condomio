import { CommonModule } from '@angular/common';
import { AfterViewInit, Component, ElementRef, EventEmitter, Input, NgZone, OnChanges, OnDestroy, Output, SimpleChanges, ViewChild } from '@angular/core';
import { TableLazyLoadEvent, TableModule } from 'primeng/table';
import { PaginatorModule } from 'primeng/paginator';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { RippleModule } from 'primeng/ripple';
import { StyleClassModule } from 'primeng/styleclass';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { OnlyDatePipe } from '../only-date.pipe';
import { SortEvent } from 'primeng/api';

export interface LazyLoadWithPageEvent extends TableLazyLoadEvent {
    currentPage: number;
    totalPages: number;
}

export type ClickTarget = {
    id: string;
    label?: string;
    icon?: string;
    title?: string;
    clickable?: boolean;
    value?: any;
};

@Component({
    selector: 'app-reusable-table',
    standalone: true,
    imports: [CommonModule, TableModule, PaginatorModule, ButtonModule, InputTextModule, RippleModule, StyleClassModule, TranslateModule, OnlyDatePipe],
    templateUrl: './reusable-table.component.html',
    styleUrls: ['./reusable-table.component.scss']
})
export class ReusableTableComponent implements AfterViewInit, OnChanges, OnDestroy {
    @ViewChild('dt') dataTable: any;
    @ViewChild('scrollContainerTop') scrollContainerTop!: ElementRef;
    private dataTableWrapper!: HTMLElement;
    private scrollbarTop!: HTMLElement;
    private initialized = false;
    private isSyncing = false;
    private resizeObserver!: ResizeObserver;

    @Input() columns: { sortField?: string; field: string; header: string; isArray?: boolean }[] = [];
    @Input() data: any[] = [];
    @Input() defaultSortField: string = '';
    @Input() defaultSortOrder: number = 1; // 1 = asc, -1 = desc
    @Input() rows: number = 10;
    @Input() totalRecords: number = 0;
    @Input() rowsPerPageOptions: number[] = [10, 25, 50];
    @Input() loading: boolean = false;
    @Input() tableTitle: string = '';
    @Input() totalPages: number = 0;
    @Output() onLazyLoad = new EventEmitter<LazyLoadWithPageEvent>();
    @Input() pageNumber = 0;

    first: number = 0;

    @Input() rowActions: { icon: string; tooltip?: string; styleClass?: string; eventName: string }[] = [];
    @Input() rowActionVisibilityFn: (actionName: string, row: any) => boolean = () => true;
    @Output() onAction = new EventEmitter<{ action: string; rowData: any }>();
    @Input() isCellClickable: (args: { column: { sortField?: string; field: string; header: string; isArray?: boolean }; rowData: any; rowIndex: number; value: any }) => boolean | ClickTarget | ClickTarget[] = () => false;
    @Output() cellActivated = new EventEmitter<{
        column: { sortField?: string; field: string; header: string; isArray?: boolean };
        rowData: any;
        rowIndex: number;
        value: any;
        targetId?: string;
        target?: ClickTarget;
        originalEvent: Event;
    }>();
    @Input() resetPageTrigger: number = 0;
    public Array = Array;

    ngOnChanges(changes: SimpleChanges): void {
        if (changes['resetPageTrigger'] && !changes['resetPageTrigger'].firstChange) {
            this.first = 0;
        }
    }

    constructor(
        private ngZone: NgZone,
        private translate: TranslateService
    ) {}

    get effectiveData(): any[] {
        return this.data ?? [];
    }

    get effectiveRows(): number {
        return this.rows;
    }

    get effectiveTotalRecords(): number {
        return this.totalRecords;
    }

    get effectiveFirst(): number {
        return this.first;
    }

    get effectiveTotalElements(): number {
        return this.effectiveTotalRecords;
    }
    // ===============================

    customSort(event: SortEvent) {
        const field = event.field as string;
        const order = event.order ?? 1;

        // emetto solo se cambia davvero
        if (field !== this.defaultSortField || order !== this.defaultSortOrder) {
            this.defaultSortField = field;
            this.defaultSortOrder = order;

            const rows = this.effectiveRows;

            const enriched: LazyLoadWithPageEvent = {
                first: 0,
                rows,
                sortField: field,
                sortOrder: order,
                filters: {},
                globalFilter: undefined,
                currentPage: 0,
                totalPages: this.effectiveTotalRecords > 0 ? this.effectiveTotalRecords : 0
            };

            Promise.resolve().then(() => {
                this.first = 0;
                this.onLazyLoad.emit(enriched);
            });
        }
    }

    onPageChange(ev: any) {
        if (this.loading) {
            return;
        }

        const first = ev.first ?? 0;
        const rows = ev.rows ?? this.effectiveRows;

        this.first = first;
        this.rows = rows;

        const currentPageZeroBased = Math.floor(first / Math.max(1, rows));

        const enriched: LazyLoadWithPageEvent = {
            first,
            rows,
            sortField: this.defaultSortField,
            sortOrder: this.defaultSortOrder,
            filters: {},
            globalFilter: undefined,
            currentPage: currentPageZeroBased,
            totalPages: this.effectiveTotalRecords > 0 ? this.effectiveTotalRecords : 0
        };

        this.onLazyLoad.emit(enriched);
        this.deferSync();
    }

    // ========== CELLE / ESPANSIONE ==========
    expandedRows: { [key: string]: boolean } = {};

    toggleExpansion(rowIndex: number, field: string): void {
        const key = `${rowIndex}-${field}`;
        this.expandedRows[key] = !this.expandedRows[key];
    }

    isExpanded(rowIndex: number, field: string): boolean {
        const key = `${rowIndex}-${field}`;
        return !!this.expandedRows[key];
    }

    isPrimeNGIcon(value: any): boolean {
        return typeof value === 'string' && value.startsWith('pi pi-');
    }

    onCellActivate(originalEvent: Event, column: { sortField?: string; field: string; header: string; isArray?: boolean }, rowData: any, rowIndex: number, target?: ClickTarget) {
        (originalEvent as any)?.stopPropagation?.();
        this.cellActivated.emit({
            column,
            rowData,
            rowIndex,
            value: rowData?.[column.field],
            targetId: target?.id,
            target,
            originalEvent
        });
    }

    toTargets(args: { column: { sortField?: string; field: string; header: string; isArray?: boolean }; rowData: any; rowIndex: number; value: any }): ClickTarget[] {
        const res = this.isCellClickable?.(args) as any;
        if (!res) return [];
        if (res === true) {
            return [
                {
                    id: 'default',
                    label: typeof args.value === 'string' ? args.value : undefined,
                    clickable: true,
                    value: args.value
                }
            ];
        }
        if (Array.isArray(res)) return res as ClickTarget[];
        if (typeof res === 'object' && 'id' in res) return [res as ClickTarget];
        return [];
    }

    isEmptyValue(value: any): boolean {
        if (value === null || value === undefined) {
            return true;
        }

        if (typeof value === 'string' && value.trim() === '') {
            return true;
        }

        if (Array.isArray(value) && value.length === 0) {
            return true;
        }

        return false;
    }
    getCellValue(rowData: any, field: string): any {
        if (!field) {
            return null;
        }

        // supporta path tipo "id.distributionCompany"
        return field.split('.').reduce((acc: any, part: string) => {
            if (acc == null) {
                return undefined;
            }
            return acc[part];
        }, rowData);
    }

    // ========== SCROLLBAR TOP ==========
    ngAfterViewInit() {
        this.initializeScrollbar();

        this.ngZone.runOutsideAngular(() => {
            this.resizeObserver = new ResizeObserver(() => {
                this.ngZone.run(() => {
                    this.updateScrollbarWidth();
                });
            });

            if (this.dataTableWrapper) {
                this.resizeObserver.observe(this.dataTableWrapper);
            }

            if (this.scrollbarTop) {
                this.resizeObserver.observe(this.scrollbarTop);
            }
        });
    }

    ngAfterViewChecked() {
        if (!this.initialized && this.dataTable && this.dataTable.value && this.dataTable.value.length > 0) {
            this.initializeScrollbar();
        }
    }

    initializeScrollbar() {
        if (this.initialized) {
            return;
        }

        if (this.dataTable && this.dataTable.el && this.dataTable.el.nativeElement && this.scrollContainerTop && this.scrollContainerTop.nativeElement) {
            const host: HTMLElement = this.dataTable?.el?.nativeElement;
            if (!host) return;

            this.dataTableWrapper = (host.querySelector('.p-datatable-scrollable-body') as HTMLElement) || (host.querySelector('.p-datatable-wrapper') as HTMLElement) || (host.querySelector('.p-datatable-scrollable-view') as HTMLElement);

            if (!this.dataTableWrapper) {
                this.dataTableWrapper = Array.from(host.querySelectorAll<HTMLElement>('*')).find((el) => {
                    const s = getComputedStyle(el);
                    const canScrollX = s.overflowX === 'auto' || s.overflowX === 'scroll';
                    return canScrollX && el.scrollWidth > el.clientWidth;
                }) as HTMLElement;
            }

            this.scrollbarTop = this.scrollContainerTop.nativeElement as HTMLElement;

            if (this.dataTableWrapper && this.scrollbarTop) {
                setTimeout(() => {
                    this.updateScrollbarWidth();

                    this.dataTableWrapper.addEventListener('scroll', this.syncScroll);
                    this.scrollbarTop.addEventListener('scroll', this.syncScroll);

                    window.addEventListener('resize', this.updateScrollbarWidth);

                    this.initialized = true;
                }, 0);
            }
        }
    }

    ngOnDestroy() {
        if (this.dataTableWrapper && this.syncScroll) {
            this.dataTableWrapper.removeEventListener('scroll', this.syncScroll);
        }
        if (this.scrollbarTop && this.syncScroll) {
            this.scrollbarTop.removeEventListener('scroll', this.syncScroll);
        }

        if (this.updateScrollbarWidth) {
            window.removeEventListener('resize', this.updateScrollbarWidth);
        }

        this.initialized = false;
    }

    private syncScroll = (event: Event) => {
        if (this.isSyncing) {
            return;
        }

        if (!this.dataTableWrapper || !this.scrollbarTop) {
            return;
        }

        const target = event.target as HTMLElement;
        this.isSyncing = true;

        if (target === this.scrollbarTop) {
            this.dataTableWrapper.scrollLeft = this.scrollbarTop.scrollLeft;
        } else if (target === this.dataTableWrapper) {
            this.scrollbarTop.scrollLeft = this.dataTableWrapper.scrollLeft;
        }

        this.isSyncing = false;
    };

    private updateScrollbarWidth = () => {
        if (!this.dataTableWrapper || !this.scrollbarTop) {
            return;
        }
        setTimeout(() => {
            const tableWidth = this.dataTableWrapper.scrollWidth;
            const scrollbarContent = this.scrollbarTop.querySelector('.scrollbar-content') as HTMLElement;
            if (scrollbarContent) {
                scrollbarContent.style.width = `${tableWidth}px`;
            }
        });
    };

    private deferSync() {
        setTimeout(() => this.updateScrollbarWidth());
    }
    //===FIME top bar===
    get reportTemplate(): string {
        const template = this.translate.instant('table.paginator.currentPageReportTemplate');

        const rows = this.effectiveRows || 1;
        const totalRecords = this.effectiveTotalRecords || 0;

        const pageIndex = this.pageNumber ?? Math.floor(this.effectiveFirst / rows);
        const currentPage = pageIndex + 1;

        const firstRecord = totalRecords === 0 ? 0 : pageIndex * rows + 1;

        return template
            .replace('{currentPage}', currentPage.toString())
            .replace('{totalPages}', this.totalPages.toString())
            .replace('{rows}', rows.toString())
            .replace('{first}', firstRecord.toString())
            .replace('{totalRecords}', totalRecords.toString());
    }
}
