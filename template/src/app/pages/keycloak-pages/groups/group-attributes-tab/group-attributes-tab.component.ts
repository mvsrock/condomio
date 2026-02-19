import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { AttributeRow } from '../models/groups-created';
import { TranslateModule } from '@ngx-translate/core';

@Component({
    selector: 'app-group-attributes-tab',
    standalone: true,
    imports: [CommonModule, FormsModule, TableModule, ButtonModule, InputTextModule, TranslateModule],
    templateUrl: './group-attributes-tab.component.html'
})
export class GroupAttributesTabComponent {
    @Input() rows: AttributeRow[] = [];
    @Output() rowsChange = new EventEmitter<AttributeRow[]>();

    @Input() mode: 'view' | 'edit' | 'create' = 'edit';

    @Output() save = new EventEmitter<Array<{ id?: string; name: string; value: string }>>();

    get isView() {
        return this.mode === 'view';
    }

    addRow() {
        if (this.isView) return;
        this.rows = [...this.rows, { id: undefined, key: '', value: '' }];
        this.rowsChange.emit(this.rows);
    }

    removeRow(i: number) {
        if (this.isView) return;
        this.rows = this.rows.filter((_, idx) => idx !== i);
        this.rowsChange.emit(this.rows);
    }

    onRowsChange() {
        this.rowsChange.emit(this.rows);
    }

    private toPayload() {
        return this.rows
            .filter((r) => r.key?.trim())
            .map((r) => ({
                ...(r.id ? { id: r.id } : {}),
                name: r.key.trim(),
                value: r.value ?? ''
            }));
    }

    emitSave() {
        if (this.isView) return;
        this.save.emit(this.toPayload());
    }
}
