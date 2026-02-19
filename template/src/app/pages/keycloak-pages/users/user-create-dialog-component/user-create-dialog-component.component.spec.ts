import { ComponentFixture, TestBed } from '@angular/core/testing';

import { UserCreateDialogComponentComponent } from './user-create-dialog-component.component';

describe('UserCreateDialogComponentComponent', () => {
    let component: UserCreateDialogComponentComponent;
    let fixture: ComponentFixture<UserCreateDialogComponentComponent>;

    beforeEach(async () => {
        await TestBed.configureTestingModule({
            imports: [UserCreateDialogComponentComponent]
        }).compileComponents();

        fixture = TestBed.createComponent(UserCreateDialogComponentComponent);
        component = fixture.componentInstance;
        fixture.detectChanges();
    });

    it('should create', () => {
        expect(component).toBeTruthy();
    });
});
