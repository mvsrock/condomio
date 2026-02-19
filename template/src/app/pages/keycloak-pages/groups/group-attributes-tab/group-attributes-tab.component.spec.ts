import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GroupAttributesTabComponent } from './group-attributes-tab.component';

describe('GroupAttributesTabComponent', () => {
    let component: GroupAttributesTabComponent;
    let fixture: ComponentFixture<GroupAttributesTabComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            imports: [GroupAttributesTabComponent]
        }).compileComponents();

        fixture = TestBed.createComponent(GroupAttributesTabComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    it('should create', () => {
        expect(component).toBeTruthy();
    });
});
