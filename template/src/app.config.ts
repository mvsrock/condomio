import { HttpClient, provideHttpClient, withInterceptors } from '@angular/common/http';
import { ApplicationConfig, importProvidersFrom, inject, provideAppInitializer } from '@angular/core';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { provideRouter, withEnabledBlockingInitialNavigation, withInMemoryScrolling } from '@angular/router';
import Aura from '@primeuix/themes/aura';
import { providePrimeNG } from 'primeng/config';
import { appRoutes } from './app.routes';
import { KeycloakService } from './app/services/keycloak/keycloak.service';
import { errorInterceptor } from './app/services/interceptor/error.interceptor';
import { requestInterceptor } from './app/services/interceptor/request.interceptor';
import { MessageService } from 'primeng/api';
import { ErrorService } from './app/services/interceptor/service/error.service';
import { JWT_OPTIONS, JwtHelperService } from '@auth0/angular-jwt';
import { TranslateLoader, TranslateModule } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';

export function kcFactory(kcService: KeycloakService): () => Promise<void> {
    return () => kcService.init();
}

export const appConfig: ApplicationConfig = {
    providers: [
        provideRouter(appRoutes, withInMemoryScrolling({ anchorScrolling: 'enabled', scrollPositionRestoration: 'enabled' }), withEnabledBlockingInitialNavigation()),
        provideHttpClient(withInterceptors([requestInterceptor, errorInterceptor])),
        provideAnimationsAsync(),
        providePrimeNG({ theme: { preset: Aura, options: { darkModeSelector: '.app-dark' } } }),
        provideAppInitializer(() => {
            const configService = inject(KeycloakService);
            return configService.init();
        }),
        JwtHelperService,
        MessageService,
        ErrorService,
        { provide: JWT_OPTIONS, useValue: JWT_OPTIONS },
        importProvidersFrom(
            TranslateModule.forRoot({
                //  defaultLanguage: getLanguageFromLocalStorage() ,
                loader: {
                    provide: TranslateLoader,
                    useFactory: httpTranslateLoader,
                    deps: [HttpClient]
                }
            })
        )
        /*   {
               provide: APP_INITIALIZER,
               useFactory: kcFactory,
               multi: true,
               deps: [KeycloakService]
           }*/
    ]
};

export function httpTranslateLoader(http: HttpClient) {
    return new TranslateHttpLoader(http);
}
/*
export function getLanguageFromLocalStorage() {
    let local = new LocalStorageService();
    debugger
    let savedLanguage = local.getItem('language');
    let windowLanguage=window.navigator.language;
    const supportedLangs = ["en", "it"];
    if(/Edg\//.test(navigator.userAgent)){
        if (windowLanguage.includes('it') && !windowLanguage.includes('it-IT')) {
            windowLanguage = windowLanguage;
        }

        if (savedLanguage === 'it') {
            savedLanguage = savedLanguage;
        }
    }else if((savedLanguage!==null && !supportedLangs.includes(savedLanguage))){
        windowLanguage=savedLanguage='en';
        local.setItem('language','en');
    }
    return (savedLanguage===null)|| windowLanguage === savedLanguage? windowLanguage : savedLanguage  ;
}*/
