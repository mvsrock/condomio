import { Injectable } from '@angular/core';
import { FormGroup } from '@angular/forms';

@Injectable({ providedIn: 'root' })
export class QueryStringService {
    toQueryString(obj: any, prefix?: string): string {
        const pairs: string[] = [];

        for (const key in obj) {
            if (!Object.prototype.hasOwnProperty.call(obj, key)) continue;

            const value = obj[key];

            // Salta valori nulli, undefined, "null" stringa, o stringa vuota
            if (value === undefined || value === null || (typeof value === 'string' && (value.trim() === '' || value.trim().toLowerCase() === 'null'))) {
                continue;
            }

            const encodedKey = encodeURIComponent(key);
            let fullKey = prefix ? `${prefix}.${encodedKey}` : encodedKey;

            // Se obj è un array e la chiave è un indice numerico
            if (Array.isArray(obj) && !isNaN(+key)) {
                const index = encodeURIComponent(key); // encode anche l'indice
                fullKey = prefix ? `${prefix}%5B${index}%5D` : `${encodedKey}`; // %5B = [, %5D = ]
            }

            if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
                const nested = this.toQueryString(value, fullKey);
                if (nested) pairs.push(nested); // evita aggiunta di stringhe vuote
            } else if (Array.isArray(value)) {
                // Array di valori primitivi
                value.forEach((item, idx) => {
                    if (item !== undefined && item !== null && !(typeof item === 'string' && (item.trim() === '' || item.trim().toLowerCase() === 'null'))) {
                        const arrayKey = `${fullKey}%5B${idx}%5D`; // fullKey[idx] encoded
                        pairs.push(`${arrayKey}=${encodeURIComponent(item)}`);
                    }
                });
            } else {
                pairs.push(`${fullKey}=${encodeURIComponent(value)}`);
            }
        }

        return pairs.join('&');
    }

    getAllInvalidControls(form: FormGroup, path: string[] = []): string[] {
        const invalid: string[] = [];
        Object.keys(form.controls).forEach((key) => {
            const control = form.get(key);
            const controlPath = [...path, key];
            if (control instanceof FormGroup) {
                invalid.push(...this.getAllInvalidControls(control, controlPath));
            } else if (control?.invalid) {
                invalid.push(controlPath.join('.'));
            }
        });
        return invalid;
    }
}
