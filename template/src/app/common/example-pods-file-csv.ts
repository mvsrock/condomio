import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class CsvDownloadService {

  downloadMemoryAsCSV(data: string[][], filename: string = 'template.csv'): void {
    const csvContent = data.map(row => row.join(',')).join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = window.URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', filename);
    link.setAttribute('target', '_blank');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    window.URL.revokeObjectURL(url);
  }

  downloadExamplePodsFile(): void {
    this.downloadMemoryAsCSV(
      [
        ['ldn'],
        ['WTT000000000001'],
        ['WTT000000000002'],
        ['WTT000000000003']
      ],
      'template_ldn.csv'
    );
  }
}
