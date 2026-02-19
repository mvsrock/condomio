package it.atlantica.controller;



import it.atlantica.PageDto;
import it.atlantica.dto.MenuItemDto;
import it.atlantica.entity.MenuItem;
import it.atlantica.exception.NotFoundException;
import it.atlantica.request.search.MenuSearchRequest;
import it.atlantica.response.PageResponse;
import it.atlantica.service.MenuItemService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/menu-items")
public class MenuItemController {
	@Autowired
	private MenuItemService menuItemService;
//@Autowired
  //  private NextPagePrefetcher prefetcher;



    @GetMapping
    public ResponseEntity<PageResponse<MenuItemDto>> getAll(@Valid MenuSearchRequest filters,
                                                            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int size,
                                                            @RequestParam() String sort, @RequestParam() String direction) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.fromString(direction), sort));

       PageDto<MenuItemDto> menuItemDtoPageDto= menuItemService.findByFilters(filters, pageable);
     /*  prefetcher.prefetchNext(
                    filters,
                    pageable,
                    menuItemDtoPageDto.totalPages(),
               (MenuSearchRequest f, Pageable p) -> menuItemService.findByFilters(f, p)
       );*/
        return ResponseEntity.ok(new PageResponse<>(menuItemDtoPageDto));
    }
	@GetMapping("/{id}")
	public ResponseEntity<MenuItem> getById(@PathVariable Long id) {
		return menuItemService.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
	}

	@PostMapping
	public ResponseEntity<MenuItem> create(@RequestBody MenuItemDto menuItem) throws NotFoundException {
		return ResponseEntity.ok(menuItemService.save(menuItem));
	}

	@PutMapping("/{id}")
	public ResponseEntity<Void> update(@PathVariable Long id, @RequestBody MenuItemDto menuItem) throws NotFoundException {
        menuItemService.update(id, menuItem);
		return ResponseEntity.noContent().build();
	}

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete( @PathVariable Long id, @RequestParam(defaultValue = "false") boolean deleteBranch ) throws NotFoundException {
        menuItemService.deleteById(id, deleteBranch);
        return ResponseEntity.noContent().build();
    }

	@GetMapping("/by-role-names")
	public ResponseEntity<List<MenuItem>> getMenuByRoleNames(@AuthenticationPrincipal Jwt jwt) {
		@SuppressWarnings("unchecked")
		List<String> roles = jwt.getClaimAsMap("realm_access") != null
				? (List<String>) jwt.getClaimAsMap("realm_access").get("roles")
				: Collections.emptyList();

		List<MenuItem> menuItems = menuItemService.getMenuItemsByRoleNames(roles);
		return ResponseEntity.ok(menuItems);

	}
}