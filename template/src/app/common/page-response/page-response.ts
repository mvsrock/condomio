export class PageResponse<T> {
    content: T[];
    totalPages: number;
    currentPage: number;
    pageSize: number;
    totalElements: number;
    pageNumber: number;
    constructor(
        content: T[] = [],
        totalPages: number = 0,
        currentPage: number = 0,
        pageSize: number = 0,
        totalElements: number = 0,
        pageNumber: number=0
    ) {
        this.content = content;
        this.totalPages = totalPages;
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.totalElements = totalElements;
        this.pageNumber=pageNumber;
    }
}