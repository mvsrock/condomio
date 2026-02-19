import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DynamicFiltersComponentComponent } from './dynamic-filters-component.component';

describe('DynamicFiltersComponentComponent', () => {
  let component: DynamicFiltersComponentComponent;
  let fixture: ComponentFixture<DynamicFiltersComponentComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DynamicFiltersComponentComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DynamicFiltersComponentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
