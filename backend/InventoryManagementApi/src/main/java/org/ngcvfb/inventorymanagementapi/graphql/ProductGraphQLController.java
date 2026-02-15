package org.ngcvfb.inventorymanagementapi.graphql;

import org.ngcvfb.inventorymanagementapi.dto.CreateProductRequest;
import org.ngcvfb.inventorymanagementapi.dto.UpdateProductRequest;
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
        Page<Product> productPage;

        if (search != null && !search.isEmpty()) {
            productPage = productService.searchProducts(search, pageable);
        } else if (categoryId != null) {
            productPage = productService.findByCategory(categoryId, pageable);
        } else {
            productPage = productService.findAll(pageable);
        }

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
        return productService.findById(id);
    }

    @QueryMapping
    public List<Category> categories() {
        return categoryService.findAll();
    }

    @MutationMapping
    public Product createProduct(@Argument CreateProductInput input) {
        CreateProductRequest request = new CreateProductRequest();
        request.setSku(input.sku());
        request.setName(input.name());
        request.setDescription(input.description());
        request.setPrice(input.price());
        request.setCurrentStock(input.currentStock());
        request.setCategoryId(input.categoryId());

        return productService.createProduct(request);
    }

    @MutationMapping
    public Product updateProduct(@Argument Long id, @Argument UpdateProductInput input) {
        UpdateProductRequest request = new UpdateProductRequest();
        request.setSku(input.sku());
        request.setName(input.name());
        request.setDescription(input.description());
        request.setPrice(input.price());
        request.setCurrentStock(input.currentStock());
        request.setCategoryId(input.categoryId());

        return productService.updateProduct(id, request);
    }

    @MutationMapping
    public Boolean deleteProduct(@Argument Long id) {
        productService.deleteProduct(id);
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
