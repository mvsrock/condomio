import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GroupsDialogComponent } from './groups-dialog.component';

describe('GroupsDialogComponent', () => {
    let component: GroupsDialogComponent;
    let fixture: ComponentFixture<GroupsDialogComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            imports: [GroupsDialogComponent]
        }).compileComponents();

        fixture = TestBed.createComponent(GroupsDialogComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    it('should create', () => {
        expect(component).toBeTruthy();
    });
});
