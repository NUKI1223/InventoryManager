package org.ngcvfb.inventorymanagementapi.graphql;

import org.ngcvfb.inventorymanagementapi.dto.ProductDto;
import org.ngcvfb.inventorymanagementapi.model.Category;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.service.CategoryService;
import org.ngcvfb.inventorymanagementapi.service.ProductService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Controller
public class ProductGraphQLController {

    private final ProductService productService;
    private final CategoryService categoryService;

    public ProductGraphQLController(ProductService productService, CategoryService categoryService) {
        this.productService = productService;
        this.categoryService = categoryService;
    }

    @QueryMapping
    public Map<String, Object> products(
            @Argument Integer page,
            @Argument Integer size,
            @Argument String search,
            @Argument Long categoryId
    ) {
        Pageable pageable = PageRequest.of(page != null ? page : 0, size != null ? size : 20);
        Page<Product> productPage = productService.searchProducts(search, categoryId, pageable);

        return Map.of(
                "content", productPage.getContent(),
                "totalElements", productPage.getTotalElements(),
                "totalPages", productPage.getTotalPages(),
                "size", productPage.getSize(),
                "number", productPage.getNumber()
        );
    }

    @QueryMapping
    public Product product(@Argument Long id) {
        return productService.getOne(id);
    }

    @QueryMapping
    public List<Category> categories() {
        return categoryService.findAll();
    }

    @MutationMapping
    public Product createProduct(@Argument CreateProductInput input) {
        ProductDto dto = new ProductDto();
        dto.setSku(input.sku());
        dto.setName(input.name());
        dto.setDescription(input.description());
        dto.setPrice(BigDecimal.valueOf(input.price()));
        dto.setCurrentStock(input.currentStock().longValue());
        dto.setCategoryId(input.categoryId());

        // Using 1L as default performedBy user ID (admin)
        return productService.create(dto, 1L);
    }

    @MutationMapping
    public Product updateProduct(@Argument Long id, @Argument UpdateProductInput input) {
        ProductDto dto = new ProductDto();
        if (input.sku() != null) dto.setSku(input.sku());
        if (input.name() != null) dto.setName(input.name());
        if (input.description() != null) dto.setDescription(input.description());
        if (input.price() != null) dto.setPrice(BigDecimal.valueOf(input.price()));
        if (input.currentStock() != null) dto.setCurrentStock(input.currentStock().longValue());
        if (input.categoryId() != null) dto.setCategoryId(input.categoryId());

        return productService.update(id, dto, 1L);
    }

    @MutationMapping
    public Boolean deleteProduct(@Argument Long id) {
        productService.softDelete(id, 1L);
        return true;
    }

    // Input record types
    public record CreateProductInput(
            String sku,
            String name,
            String description,
            Double price,
            Integer currentStock,
            Long categoryId
    ) {}

    public record UpdateProductInput(
            String sku,
            String name,
            String description,
            Double price,
            Integer currentStock,
            Long categoryId
    ) {}
}
