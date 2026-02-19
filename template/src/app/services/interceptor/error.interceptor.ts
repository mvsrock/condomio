import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { ErrorService } from './service/error.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
    const errorService = inject(ErrorService);
    return next(req).pipe(
        catchError((error: HttpErrorResponse) => {
            if (error) {
                // Gestione degli errori
                /* if (error.status === 302 || error.status === 0) {
          auth.logout();
        } else if (error.status === 401 || error.status === 403) {
          auth.logout();
        } else if (error.status === 500) {
          // Gestione degli errori del server
          console.error('Server error - please try again later');
        }*/
            }

            return throwError(() => errorService.handleError(error));
        })
    );
};
