// expose-control.directive.ts
import { Directive, OnInit } from '@angular/core';
import { NgControl } from '@angular/forms';
import { RxFormControl } from '@rxweb/reactive-form-validators';

@Directive({
    selector: '[exposeControl]',
    standalone: true
})
export class ExposeControlDirective implements OnInit {
    constructor(public ngControl: NgControl) {}

    public get formcontrol(): RxFormControl {
        // Il cast dovrebbe essere sicuro se usato con Rxweb
        return this.ngControl.control as RxFormControl;
    }

    ngOnInit() {}
}
