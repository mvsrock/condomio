import { TableLazyLoadEvent } from 'primeng/table';

export interface LazyLoadWithPageEvent extends TableLazyLoadEvent {
    currentPage: number;
    totalPages: number;
}
