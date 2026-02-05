package org.ngcvfb.inventorymanagementapi.controller;


import java.lang.reflect.Method;
import java.util.Map;

import io.jsonwebtoken.Jwt;
import org.ngcvfb.inventorymanagementapi.dto.ProductDto;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.service.ProductService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public Page<Product> list(
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "categoryId", required = false) Long categoryId,
            @PageableDefault(size = 20, sort = "name") Pageable pageable
    ) {
        return productService.searchProducts(q, categoryId, pageable);
    }

    @GetMapping("/{id}")
    public Product getOne(@PathVariable Long id) {
        return productService.getOne(id);
    }

    @PostMapping
    public Product create(@RequestBody ProductDto dto, Authentication authentication) {
        Long userId = Long.parseLong(authentication.getName());
        return productService.create(dto, userId);
    }

    @PutMapping("/{id}")
    public Product update(@PathVariable Long id, @RequestBody ProductDto dto, Authentication authentication) {
        Long userId = Long.parseLong(authentication.getName());
        return productService.update(id, dto, userId);
    }

    @DeleteMapping("{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> delete(@PathVariable Long id, Authentication authentication) {
        Long userId = Long.parseLong(authentication.getName());
        productService.softDelete(id, userId);
        return ResponseEntity.noContent().build();
    }
}

