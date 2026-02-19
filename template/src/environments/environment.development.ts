const protocol = window.location.protocol;
const hostname = window.location.hostname;

const gatewayPort = ':9090';
const gatewayHost = `${protocol}//${hostname}${gatewayPort}`;
const keycloak_service = '/keycloak-service';
const readings = '/readings';
export const environment = {
    production: false,

    menus: {
        getMenuItemsByRoles: gatewayHost + keycloak_service + '/menu-items/by-role-names',
        get: gatewayHost + keycloak_service + '/menu-items',
        update: gatewayHost + keycloak_service + '/menu-items/',
        delete: gatewayHost + keycloak_service + '/menu-items/'
    },

    keycloak: {
        url: 'http://localhost:8082',
        realm: 'atlantica',
        clientId: 'login',
        redirectUrl: 'http://localhost:4200'
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
    },

    distribution_company: {
        get: gatewayHost + readings + '/distributionCompany'
    },
    general_info: {
        get: gatewayHost + readings + '/implantsView',
        getCount: gatewayHost + readings + '/implantsView/countByDistributionId?distributionId='
    },
    reports: {
        measureGroupReverseView: gatewayHost + readings + '/reports/measureGroupReverseView',
        measureGroupReverseViewDownload: gatewayHost + readings + '/reports/measureGroupReverseView/download/csv',
        measureGroupFraudView: gatewayHost + readings + '/reports/measureGroupFraudView',
        measureGroupFraudViewDownload: gatewayHost + readings + '/reports/measureGroupFraudView/download/csv',
        measureGroupLossView: gatewayHost + readings + '/reports/measureGroupLossView',
        measureGroupLossViewDownload: gatewayHost + readings + '/reports/measureGroupLossView/download/csv',
        discardedImplants: gatewayHost + readings + '/reports/discardedImplants',
        discardedImplantsDownload: gatewayHost + readings + '/reports/discardedImplants/download',
        suspectedFraud: gatewayHost + readings + '/reports/suspectedFraud',
        suspectedFraudDownload: gatewayHost + readings + '/reports/suspectedFraud/download/csv',
        statusDevicesReport: gatewayHost + readings + '/reports/status_tlt_and_devices/statusDevicesReport',
        statusDevicesTLT: gatewayHost + readings + '/reports/status_tlt_and_devices/statusDevicesTLT',
        statusDevicesTLTDownload: gatewayHost + readings + '/reports/status_tlt_and_devices/statusDevicesTLT/download'
    },

    dailyReadings: {
        get: gatewayHost + readings + '/historicalReadings/mgDailyReadingViewNew'
    },
    filterdata: {
        communicationtype: gatewayHost + readings + '/api/v1/filterdata/communicationtype',
        eventType: gatewayHost + readings + '/api/v1/filterdata/eventtype',
        producerUniqueList: gatewayHost + readings + '/api/v1/filterdata/producer'
    },
    alarm_addOn: {
        get: gatewayHost + readings + '/alarm/mgAlarmView'
    },
    event_addOn: {
        get: gatewayHost + readings + '/event/eventsViews'
    },
    eventMetrological: {
        get: gatewayHost + readings + '/eventMetrological',
        retrieval: gatewayHost + readings + '/eventMetrological/retrieval',
        upload: gatewayHost + readings + '/eventMetrological/upload'
    },
    scaleFactor: {
        get: gatewayHost + readings + '/scaleFactory',
        upload: gatewayHost + readings + '/scaleFactory/upload'
    },
    recovery_fw_crc: {
        get: gatewayHost + readings + '/recovery_fw_crc',
        upload: gatewayHost + readings + '/recovery_fw_crc/upload'
    },
    filefw: {
        get: gatewayHost + readings + '/filefw',
        upload: gatewayHost + readings + '/filefw/upload',
        download: gatewayHost + readings + '/filefw/download'
    },
    fwTarget: {
        get: gatewayHost + readings + '/fw_target',
        download: gatewayHost + readings + '/fw_target/download'
    }
};
