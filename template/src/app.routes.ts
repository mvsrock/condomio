import { Routes } from '@angular/router';
import { AppLayout } from './app/layout/component/app.layout';
import { Notfound } from './app/pages/demo/notfound/notfound';
import { Access } from './app/pages/demo/auth/access';
import { roleMatch } from './app/services/jwt_helper/role-match.guard';

export const appRoutes: Routes = [
    {
        path: '',
        component: AppLayout,
        children: [
            {
                path: '',
                canMatch: [roleMatch('authority_admin')],
                //     canActivate: [RoleGuard],
                loadComponent: () => import('./app/pages/dashboard/dashboard').then((c) => c.Dashboard)
            },
            {
                path: '',
                canMatch: [roleMatch('user')],
                //  canActivate: [RoleGuard],
                loadComponent: () => import('./app/pages/dashboard/dashboardUser').then((c) => c.DashboardUser)
            },
            {
                path: 'roles',
                // canActivate: [RoleGuard],
                canMatch: [roleMatch('authority_admin')],
                loadComponent: () => import('./app/pages/keycloak-pages/roles/roles.component').then((c) => c.RolesComponent)
            },
            {
                path: 'groups',
                //  canActivate: [RoleGuard],
                canMatch: [roleMatch('authority_admin')],
                loadComponent: () => import('./app/pages/keycloak-pages/groups/groups.component').then((c) => c.GroupsComponent)
            },
            {
                path: 'users',
                //   canActivate: [RoleGuard],
                canMatch: [roleMatch('authority_admin')],
                loadComponent: () => import('./app/pages/keycloak-pages/users/users.component').then((c) => c.UsersComponent)
            },
            {
                path: 'menus',
                //   canActivate: [RoleGuard],
                canMatch: [roleMatch('authority_admin')],
                loadComponent: () => import('./app/pages/admin/menu/menu.component').then((c) => c.MenuComponent)
            }
        ]
    },
    { path: 'access', component: Access },
    { path: 'notfound', component: Notfound },

    { path: '**', redirectTo: 'notfound' }
];
