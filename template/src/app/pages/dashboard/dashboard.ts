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
    selector: 'app-dashboard',
    imports: [],
    template: ` Dashboard per ora vuota poi si vedrà `
})
export class Dashboard implements OnInit {
    ngOnInit(): void {}
}
