package it.condomio.repository.custom;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import it.condomio.dto.MenuItemDto;
import it.condomio.request.search.MenuSearchRequest;

public interface MenuItemRepositoryCustom {
    Page<MenuItemDto> findByFilters(MenuSearchRequest filters, Pageable pageable);

}
