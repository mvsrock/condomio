import { HttpErrorResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';
import { MessageService } from 'primeng/api';

@Injectable({
    providedIn: 'root'
})
export class ErrorService {
    constructor(
        private messageService: MessageService,
        private t: TranslateService
    ) {}
    handleError(error: HttpErrorResponse) {
        let errorMessage = '';
        if (error?.error instanceof ErrorEvent) {
            // Errore lato client

            errorMessage = `Client-side error: ${error.error.message}`;

            this.messageService.add({ severity: 'error', summary: 'Error', detail: errorMessage });
        } else {
            // Errore lato server
            if (error?.error?.errorCodes) {
                error.error.errorCodes.forEach((element: any) => {
                    this.t.get('errors.' + element).subscribe((translated: string) => {
                        this.messageService.add({ severity: 'error', summary: this.t.instant('common.error'), detail: translated });
                    });
                });
            } else if (error?.error) {
                this.messageService.add({ severity: 'error', summary: 'Error', detail: error?.error });
            } else if (error?.error?.message) {
                this.messageService.add({ severity: 'error', summary: 'Error', detail: error?.error?.message });
            }
        }
    }
}
