import { AfterContentInit, Component, ContentChild, ElementRef, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AbstractControl, FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RxFormControl, RxFormGroup, RxReactiveFormsModule } from '@rxweb/reactive-form-validators';
import { TranslateModule } from '@ngx-translate/core';
import { ExposeControlDirective } from './expose-control-directive';

@Component({
    selector: 'input-form-control',
    standalone: true,
    imports: [CommonModule, FormsModule, ReactiveFormsModule, RxReactiveFormsModule, TranslateModule],
    template: `
        <div class="form-group" *ngIf="selfControl">
            <label *ngIf="label" [class.font-bold]="mandatory" class="block mb-2">
                {{ label | translate }}
                <span *ngIf="mandatory" class="text-red-500">*</span>
            </label>

            <ng-content></ng-content>

            <div *ngIf="invalid" class="error">
                <div *ngFor="let error of errors">{{ error | translate }}</div>
            </div>
        </div>
    `,
    styles: [
        `
            .error {
                color: red;
            }
        `
    ]
})
export class InputFormControlComponent implements AfterContentInit {
    @ContentChild(ExposeControlDirective) exposedControl!: ExposeControlDirective;
    @Input() groupName?: string;
    public selfControl?: AbstractControl;

    ngAfterContentInit(): void {
        if (this.exposedControl) {
            this.selfControl = this.exposedControl.formcontrol;
        } else {
            console.warn('AtlanticaFormControlComponent: No ExposeControlDirective found in content projection.');
        }
    }

    constructor(private elementRef: ElementRef) {}

    @Input() set control(c: AbstractControl | null) {
        this.selfControl = c || undefined;
    }
    @Input() label?: string;

    public get invalid(): boolean {
        if (this.selfControl) {
            return this.selfControl.invalid && (this.selfControl.touched || this.selfControl.dirty);
        }

        return false;
    }

    public get mandatory(): boolean {
        if (this.selfControl instanceof RxFormControl || this.selfControl instanceof RxFormGroup) {
            if (this.selfControl.validator) {
                const validator = this.selfControl.validator({} as AbstractControl);
                return !!validator?.['required'];
            }
        }
        return false;
    }

    public get errors(): string[] | null {
        const errors: string[] = [];
        if (this.selfControl?.errors) {
            for (const errorName in this.selfControl.errors) {
                if (this.selfControl.errors.hasOwnProperty(errorName) && this.selfControl.errors[errorName]?.message) {
                    errors.push(this.selfControl.errors[errorName].message);
                }
            }
            return errors.length > 0 ? errors : null;
        }
        if (this.selfControl instanceof RxFormGroup) {
            for (const key in this.selfControl.controls) {
                const control = this.selfControl.controls[key];
                if (control.invalid && (control.touched || control.dirty) && control.errors) {
                    for (const errorName in control.errors) {
                        if (control.errors.hasOwnProperty(errorName) && control.errors[errorName]?.message) {
                            errors.push(control.errors[errorName].message);
                        }
                    }
                }
            }
        }
        return errors.length > 0 ? errors : null;
    }
}
