package it.atlantica.response;

import it.atlantica.PageDto;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.Page;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PageResponse<T>  {
    private List<T> content;
    private int pageNumber;
    private int pageSize;
    private long totalElements;
    private int totalPages;
    private boolean last;

    
    public PageResponse(Page<T> page) {
        this.content = page.getContent();
        this.pageNumber = page.getNumber();
        this.pageSize = page.getSize();
        this.totalElements = page.getTotalElements();
        this.totalPages = page.getTotalPages();
        this.last = page.isLast();
    }

    // <-- nuovo
    public PageResponse(PageDto<T> dto) {
        this.content = dto.content();
        this.pageNumber = dto.pageNumber();
        this.pageSize = dto.pageSize();
        this.totalElements = dto.totalElements();
        this.totalPages = dto.totalPages();
        this.last = dto.last();
    }
}
