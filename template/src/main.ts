import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app.config';
import { AppComponent } from './app.component';
import { enableProdMode } from '@angular/core';
import { environment } from './environments/environment.development';

console.log('env ' + environment.production);
if (environment.production) {
    enableProdMode();
}
bootstrapApplication(AppComponent, appConfig).catch((err) => console.error(err));
