import { CanActivateFn, Router } from '@angular/router';
import { KeycloakService } from '../keycloak/keycloak.service';
import { inject } from '@angular/core';

export const authGuard: CanActivateFn = (): boolean => {
    const tokenService: KeycloakService = inject(KeycloakService);
    const router: Router = inject(Router);
    if (tokenService.keycloak?.isTokenExpired()) {
        router.navigate(['login']);
        return false;
    }
    return true;
};
