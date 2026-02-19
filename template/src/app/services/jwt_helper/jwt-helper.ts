import { Injectable } from '@angular/core';
import { JwtHelperService } from '@auth0/angular-jwt';

@Injectable({
    providedIn: 'root'
})
export class jwtHelper {
    constructor(private jwtHelper: JwtHelperService) {}
    async getToken(): Promise<string | null> {
        const token = localStorage.getItem('token');
        if (!token) {
            // Attendi un attimo per evitare richiesta senza token
            await new Promise((resolve) => setTimeout(resolve, 100));
        }
        return token;
    }

    async getUserRoles(): Promise<string[]> {
        const token = await this.getToken();
        if (!token) return [];

        try {
            const decoded: any = this.decoderToken(token);
            return decoded?.realm_access?.roles || [];
        } catch (e) {
            return [];
        }
    }

    async hasRole(expectedRoles: string[]): Promise<boolean> {
        const userRoles = await this.getUserRoles();
        return expectedRoles.some((role) => userRoles.includes(role));
    }

    public decoderToken(token: string) {
        return this.jwtHelper.decodeToken(token);
    }
}
