package it.atlantica.repository.custom;


import it.atlantica.dto.MenuItemDto;
import it.atlantica.request.search.MenuSearchRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface MenuItemRepositoryCustom {
    Page<MenuItemDto> findByFilters(MenuSearchRequest filters, Pageable pageable);

}
