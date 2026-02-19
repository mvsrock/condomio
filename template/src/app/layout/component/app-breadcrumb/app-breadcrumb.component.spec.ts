import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AppBreadcrumbComponent } from './app-breadcrumb.component';

describe('AppBreadcrumbComponent', () => {
    let component: AppBreadcrumbComponent;
    let fixture: ComponentFixture<AppBreadcrumbComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            imports: [AppBreadcrumbComponent]
        }).compileComponents();

        fixture = TestBed.createComponent(AppBreadcrumbComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    it('should create', () => {
        expect(component).toBeTruthy();
    });
});
