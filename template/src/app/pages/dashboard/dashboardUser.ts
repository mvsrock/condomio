import { Component, OnInit } from '@angular/core';
import { alpha, email, required } from '@rxweb/reactive-form-validators';

export class User {
    @required({ message: 'aaa' })
    @alpha()
    firstName: string = '';

    @required({ message: 'email fratm' })
    @email()
    email: string = '';
}
@Component({
    selector: 'app-dashboard-user',
    imports: [],
    template: ` Dashboard User con permesso Users `
})
export class DashboardUser implements OnInit {
    ngOnInit(): void {}
}
