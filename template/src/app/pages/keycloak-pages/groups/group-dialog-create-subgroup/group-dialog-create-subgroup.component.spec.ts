import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GroupDialogCreateSubgroupComponent } from './group-dialog-create-subgroup.component';

describe('GroupDialogCreateSubgroupComponent', () => {
    let component: GroupDialogCreateSubgroupComponent;
    let fixture: ComponentFixture<GroupDialogCreateSubgroupComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            imports: [GroupDialogCreateSubgroupComponent]
        }).compileComponents();

        fixture = TestBed.createComponent(GroupDialogCreateSubgroupComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    it('should create', () => {
        expect(component).toBeTruthy();
    });
});
