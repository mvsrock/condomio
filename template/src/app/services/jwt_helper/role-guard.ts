import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot } from '@angular/router';
import { jwtHelper } from './jwt-helper';
import { KeycloakService } from '../keycloak/keycloak.service';

@Injectable({
    providedIn: 'root'
})
export class RoleGuard implements CanActivate {
    constructor(
        private authService: jwtHelper,
        private router: Router,
        private keycloak: KeycloakService
    ) {}

    async canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): Promise<boolean> {
        const expectedRoles = route.data['roles'] as string[]; // es. ['ADMIN', 'USER']
        const userRole = this.authService.getUserRoles();
        if (expectedRoles == undefined) {
            //rotta non protetta
            return true;
        }
        if ((await userRole) && (await this.authService.hasRole(expectedRoles))) {
            return true;
        }

        // this.keycloak.logout();
        this.router.navigate(['access']);
        return false;
    }
}
