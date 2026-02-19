import { Injectable } from '@angular/core';
import Keycloack from 'keycloak-js';
import { UserProfile } from './user-profile';
import { LocalStorageService } from '../local-storace/local-storage';
import { TranslateService } from '@ngx-translate/core';
import { environment } from '../../../environments/environment.development';
import { ReplaySubject } from 'rxjs';

@Injectable({
    providedIn: 'root'
})
export class KeycloakService {
    private _keycloack: Keycloack | undefined;
    private _profile: UserProfile | undefined;
    constructor(
        private localStorageService: LocalStorageService,
        private traslate: TranslateService
    ) {}
    private _ready = new ReplaySubject<boolean>(1);
    ready$ = this._ready.asObservable();
    get keycloak() {
        if (!this._keycloack) {
            this._keycloack = new Keycloack({
                url: environment.keycloak.url,
                realm: environment.keycloak.realm,
                clientId: environment.keycloak.clientId
            });
        }
        return this._keycloack;
    }

    get profile(): UserProfile | undefined {
        return this._profile;
    }
    async init() {
        const authenticated = await this.keycloak?.init({
            onLoad: 'check-sso'
            //   silentCheckSsoRedirectUri: window.location.origin + '/assets/silent-check-sso.html',
            //  pkceMethod: 'S256',
        });

        if (authenticated) {
            this.localStorageService.setItem('token', this.keycloak?.token as string);
            this._ready.next(true);
            this._profile = (await this.keycloak?.loadUserProfile()) as UserProfile;
            this._profile.token = this.keycloak?.token;

            const profile = await this.keycloak.loadUserProfile();
            //  this.localStorageService.setItem('language', profile.attributes?.['locale'] as string);
            if ((profile.attributes?.['locale'] as string) == undefined) {
                this.localStorageService.setItem('language', 'en');
            } else {
                this.localStorageService.setItem('language', profile.attributes?.['locale'] as string);
            }
            this.traslate.setDefaultLang(this.localStorageService.getItem('language'));
        } else {
            // Sessione scaduta
            console.warn('Sessione scaduta: redirect al login');
            await this.keycloak.login({ redirectUri: window.location.origin + '/' });
        }
    }
    async refreshToken(minValidity: number = 60): Promise<boolean> {
        try {
            await this.keycloak.updateToken(minValidity);
            this.localStorageService.setItem('token', this.keycloak.token as string);
            if (this._profile) {
                this._profile.token = this.keycloak.token;
            }
            return true;
        } catch (error) {
            console.error('Errore durante il refresh del token', error);
            await this.keycloak.logout({ redirectUri: environment.keycloak.redirectUrl });
            return false;
        }
    }

    login(): Promise<void> {
        return this.keycloak.login();
    }

    logout(): Promise<void> {
        this.localStorageService.clear();
        return this.keycloak.logout({ redirectUri: environment.keycloak.redirectUrl });
    }
}
