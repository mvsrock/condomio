import { Component, EventEmitter, Input, Output } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { FilterConfig } from './filter-config.model';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { DatePickerModule } from 'primeng/datepicker';
import { SelectModule } from 'primeng/select';
import { RxFormGroup } from '@rxweb/reactive-form-validators';
import { TranslateModule } from '@ngx-translate/core';

@Component({
    selector: 'app-dynamic-filters-component',
    imports: [CommonModule, ReactiveFormsModule, DatePickerModule, SelectModule, InputTextModule, ButtonModule, TranslateModule],
    templateUrl: './dynamic-filters-component.component.html',
    styleUrl: './dynamic-filters-component.component.scss'
})
export class DynamicFiltersComponent {
    @Input() title = '';
    @Input() filters: FilterConfig[] = [];

    @Input() formGroup!: RxFormGroup;

    @Output() apply = new EventEmitter<any>();
    @Output() reset = new EventEmitter<void>();
    @Output() filtersVisibilityChange = new EventEmitter<boolean>();
    @Output() filterChange = new EventEmitter<{ key: string; value: any }>();

    showFilters = false;

    toggleFilters(): void {
        this.showFilters = !this.showFilters;
        this.isOpen();
    }

    onApply(): void {
        if (!this.formGroup) return;

        if (this.formGroup.invalid) {
            this.formGroup.markAllAsTouched();
            return;
        }

        this.apply.emit(this.formGroup.value);
        this.isOpen();
    }

    onFilterChange(key: string, value: any) {
        this.filterChange.emit({ key, value });
    }
    onReset(): void {
        if (!this.formGroup) return;

        this.formGroup.reset();
        this.reset.emit();

        this.showFilters = false;
        this.isOpen();
    }
    isOpen(): void {
        this.filtersVisibilityChange.emit(this.showFilters);
    }
}
