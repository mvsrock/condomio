import { Component, OnInit } from '@angular/core';
import { RouterModule } from '@angular/router';
import { TranslateModule, TranslateService } from '@ngx-translate/core';
import { ToastModule } from 'primeng/toast';

@Component({
    selector: 'app-root',
    standalone: true,
    imports: [RouterModule, ToastModule, TranslateModule],
    template: ` <p-toast></p-toast>
        <router-outlet></router-outlet>`
})
export class AppComponent implements OnInit {
    constructor(private translate: TranslateService) {}
    ngOnInit(): void {
        this.translate.use(localStorage.getItem('language') as string);
    }
}
