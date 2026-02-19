import { CanMatchFn } from '@angular/router';
import { inject } from '@angular/core';
import { jwtHelper } from './jwt-helper';
import { KeycloakService } from '../keycloak/keycloak.service';
import { firstValueFrom } from 'rxjs';
import { filter, take } from 'rxjs/operators';

export function roleMatch(...roles: string[]): CanMatchFn {
    return async () => {
        const auth = inject(jwtHelper);
        const kc = inject(KeycloakService);
        await firstValueFrom(kc.ready$.pipe(filter(Boolean), take(1)));
        const userRoles = await auth.getUserRoles();
        const ok = roles.some((r) => userRoles.includes(r));
        return ok;
    };
}
