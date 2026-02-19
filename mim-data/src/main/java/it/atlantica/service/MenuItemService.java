package it.atlantica.service;


import it.atlantica.PageDto;
import it.atlantica.dto.MenuItemDto;
import it.atlantica.entity.MenuItem;
import it.atlantica.entity.keycloak.KeycloakRole;
import it.atlantica.exception.NotFoundException;
import it.atlantica.repository.MenuItemRepository;
import it.atlantica.repository.keycloak.KeycloakRoleRepository;
import it.atlantica.request.search.MenuSearchRequest;
import it.atlantica.service.keycloak.RoleService;
import org.keycloak.representations.idm.RoleRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class MenuItemService {
    @Autowired
    private MenuItemRepository menuItemRepository;
    @Autowired
    private KeycloakRoleRepository keycloakRoleRepository;
    @Autowired
    private RoleService roleService;


  /*@Cacheable(
            cacheNames = "menuSearch",
            condition = "@dynamicYamlProperties.cache.enabled",
            unless     = "#result == null || #result.content().isEmpty()",
            key = "T(java.util.Objects).hash(" +
                    "T(java.util.List).of(" +
                    "T(java.util.Objects).toString(#filters?.label, '')," +
                    "T(java.util.Objects).toString(#filters?.parent, '')," +
                    "T(java.util.Objects).toString(#filters?.roleId, '')," +
                    "#pageable.pageNumber, #pageable.pageSize, #pageable.sort.toString())" +
                    ")"
    )
    @CachePreload(
            cacheName = "menuSearch",
            filtersClass = MenuSearchRequest.class,
            pageSize = 10,
            sort = "label,ASC"
    )*/
    public PageDto<MenuItemDto> findByFilters(MenuSearchRequest filters, Pageable pageable) {
        return PageDto.fromPage(menuItemRepository.findByFilters(filters, pageable));
    }

    public List<MenuItem> findAll() {
        return menuItemRepository.findAll();
    }

    public Optional<MenuItem> findById(Long id) {
        return menuItemRepository.findById(id);
    }
    
   // @CacheEvict(cacheNames = "menuSearch", allEntries = true)
    public MenuItem save(MenuItemDto dto) throws NotFoundException {
        MenuItem item = new MenuItem();
        item.setItem(dto.getItem());
        item.setLabel(dto.getLabel());
        item.setDescription(dto.getDescription());
        item.setVisualOrder(dto.getVisualOrder());
        item.setUri(dto.getUri());
        item.setIcon(dto.getIcon());
        item.setVisible(dto.isVisible());
        if (dto.getParentId() != null) {
            Optional<MenuItem> parent = menuItemRepository.findById(dto.getParentId());
            if(parent.isPresent()) {
                item.setParent(parent.get());
            }else {
                throw new NotFoundException("parentId");
            }

        }
        if (dto.getRoleId() != null) {
            RoleRepresentation role = roleService.getRealmRoleById(dto.getRoleId());
            if (role != null) {
                item.setRole(roleService.fromRepresentation(role));
            }
        }
        return   menuItemRepository.save(item);
    }

    public MenuItem update(Long id, MenuItemDto menuItem) throws NotFoundException {
        MenuItem existing = menuItemRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("menuItemId"));

        existing.setItem(menuItem.getItem());
        existing.setLabel(menuItem.getLabel());
        existing.setDescription(menuItem.getDescription());

        if (menuItem.getParentId() != null) {
            MenuItem parent = menuItemRepository.findById(menuItem.getParentId())
                    .orElseThrow(() -> new NotFoundException("parentId"));
            existing.setParent(parent);
        }

        existing.setVisualOrder(menuItem.getVisualOrder());
        existing.setUri(menuItem.getUri());
        existing.setIcon(menuItem.getIcon());
        existing.setVisible(menuItem.isVisible());

        if (menuItem.getRoleId() != null) {
            RoleRepresentation role = roleService.getRealmRoleById(menuItem.getRoleId());
            if (role != null) {
                existing.setRole(roleService.fromRepresentation(role));
            }
        }

        return menuItemRepository.save(existing);
    }

    public void deleteById(Long id, boolean deleteRecursively) throws NotFoundException {
        MenuItem menuItem = menuItemRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("menuId"));

        List<MenuItem> children = menuItemRepository.findByParent(menuItem);
        if (deleteRecursively) {
            deleteRecursive(menuItem);
        } else {
            for (MenuItem child : children) {
                child.setParent(menuItem.getParent());
            //    child.setVisible(menuItem.isVisible());
                menuItemRepository.save(child);
            }
            menuItemRepository.deleteById(id);
        }
    }

    private void deleteRecursive(MenuItem menuItem) {
        List<MenuItem> children = menuItemRepository.findByParent(menuItem);
        for (MenuItem child : children) {
            deleteRecursive(child);
        }
        menuItemRepository.delete(menuItem);
    }


    public List<MenuItem> getMenuItemsByRoleNames(List<String> roleNames) {
        List<KeycloakRole> roles = keycloakRoleRepository.findByNameIn(roleNames);
        List<MenuItem> allMenuItems = menuItemRepository.findByRoles(roles);
        return allMenuItems.stream()
                .filter(this::isMenuItemVisible)
                .collect(Collectors.toList());
    }

    public boolean isMenuItemVisible(MenuItem item) {
        if (!item.isVisible()) {
            return false;
        }
        if (item.getParent() != null && !item.getParent().isVisible()) {
            return false;
        }
        return item.getParent() == null || isMenuItemVisible(item.getParent());
    }
}