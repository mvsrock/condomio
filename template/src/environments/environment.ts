const protocol = window.location.protocol;
const hostname = window.location.hostname;
const gatewayPort = ':9090';
const keycloak_service='/keycloak-service'
const gatewayHost = `${protocol}//${hostname}${gatewayPort}`;


export const environment = {
    production: true,

    menus: {
        getMenuItemsByRoles: gatewayHost + keycloak_service + '/menu-items/by-role-names',
        get: gatewayHost + keycloak_service + '/menu-items',
        update: gatewayHost + keycloak_service + '/menu-items/',
        delete: gatewayHost + keycloak_service + '/menu-items/'
    },

    keycloak: {
        url: `${window.location.protocol}//${window.location.hostname}:8082`,
        realm: 'atlantica',
        clientId: 'login',
        redirectUrl: window.location.origin
    },

    users: {
        get: gatewayHost + keycloak_service + '/users',
        create: gatewayHost + keycloak_service + '/users',
        update: gatewayHost + keycloak_service + '/users',
        disable: (userId: string) => gatewayHost + keycloak_service + '/users/' + userId + '/disable',
        deleteUserFromCompany: (idUser: string, groupId: string): string => gatewayHost + keycloak_service + '/users?userId=' + idUser + '&groupId=' + groupId,
        delete: (userId: string) => gatewayHost + keycloak_service + '/users/' + userId,
        user_distribution_not_in: (userId: string) => gatewayHost + keycloak_service + '/users/' + userId + '/not_groups',
        addUserToGroups: (userId: string) => gatewayHost + keycloak_service + '/users/' + userId + '/add_groups'
    },

    groups: {
        get: gatewayHost + keycloak_service + '/groups',
        created: gatewayHost + keycloak_service + '/groups',
        update: gatewayHost + keycloak_service + '/groups/',
        updateAttr: (groupId: string) => gatewayHost + keycloak_service + '/groups/' + groupId + '/attributes',
        deleted: (groupId: string) => gatewayHost + keycloak_service + '/groups/' + groupId,
        createSubGroup: (groupId: string) => gatewayHost + keycloak_service + '/groups/' + groupId + '/subGroups',
        findSubGroupById: (distributionId: string) => gatewayHost + keycloak_service + '/groups/' + distributionId
    },

    roles: {
        get: gatewayHost + keycloak_service + '/roles',
        created: gatewayHost + keycloak_service + '/roles',
        update: gatewayHost + keycloak_service + '/roles/',
        deleted: (roleId: string) => gatewayHost + keycloak_service + '/roles?roleId=' + roleId
    }
};
