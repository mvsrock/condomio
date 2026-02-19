package it.atlantica;

import org.springframework.data.domain.Page;

import java.util.ArrayList;

public record PageDto<T> (
        java.util.List<T> content,
        int pageNumber,
        int pageSize,
        long totalElements,
        int totalPages,
        boolean last
)   {

    public static <T> PageDto<T> fromPage(Page<T> p) {
        // Copia in ArrayList per evitare UnmodifiableRandomAccessList
        return new PageDto<>(
                new ArrayList<>(p.getContent()),
                p.getNumber(),
                p.getSize(),
                p.getTotalElements(),
                p.getTotalPages(),
                p.isLast()
        );
    }

}