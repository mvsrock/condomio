export type FilterType = 'text' | 'number' | 'date' | 'select';

export interface FilterOption {
  label: string;
  value: any;
}

export interface FilterConfig {
    key: string; // es: "fromDate", "toDate", "distributionCompany"
    label: string; // etichetta da mostrare
    type: FilterType; // 'text' | 'number' | 'date' | 'select'
    placeholder?: string;
    options?: FilterOption[]; // usato se type = 'select'
    emitOnChange?: boolean; //fa ritornare l evento di selezione della select
}
