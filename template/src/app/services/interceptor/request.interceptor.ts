import { inject } from '@angular/core';
import { HttpInterceptorFn } from '@angular/common/http';
import { from, switchMap } from 'rxjs';
import { KeycloakService } from '../keycloak/keycloak.service';

export const requestInterceptor: HttpInterceptorFn = (req, next) => {
    const _keycloak = inject(KeycloakService);

    return from(_keycloak.refreshToken()).pipe(
        switchMap(() => {
            const token = _keycloak.keycloak.token;

            if (!token) {
                // Se non ho token, passo la richiesta senza header Authorization
                return next(req);
            }

            const clonedRequest = req.clone({
                setHeaders: {
                    Authorization: `Bearer ${token}`
                }
            });

            return next(clonedRequest);
        })
    );
};
