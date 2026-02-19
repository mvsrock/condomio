import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'onlyDate',
  standalone: true
})
export class OnlyDatePipe implements PipeTransform {
  transform(value: string | Date | number | null | undefined): string {
    if (value === null || value === undefined) {
      return '';
    }

    // se è un numero (es. 0, 123), lo ritorni così com'è (o formattato come vuoi)
    if (typeof value === 'number') {
      return value.toString();
    }
    let str: string;

    if (value instanceof Date) {
      // 2019-10-01T00:43:54.925Z
      str = value.toISOString();
    } else {
      str = value.toString();
    }

    // Regex:
    //  - cattura:  (YYYY-MM-DD)  [T o spazio]  (HH:mm:ss)   e poi qualsiasi cosa dopo
    //  - sostituisce con: "YYYY-MM-DD HH:mm:ss"
    const trimmed = str.replace(
      /^(\d{4}-\d{2}-\d{2})[T ](\d{2}:\d{2}:\d{2}).*$/,
      '$1 $2'
    );

    return trimmed;
  }
  
}