package org.ngcvfb.inventorymanagementapi.controller;


import java.lang.reflect.Method;
import java.util.Map;

import io.jsonwebtoken.Jwt;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
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
@Tag(name = "Products", description = "API для управления товарами")
@SecurityRequirement(name = "bearer-jwt")
public class ProductController {
    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    @Operation(summary = "Получить список товаров",
               description = "Возвращает пагинированный список товаров с опциональными фильтрами по названию/SKU и категории")
    @ApiResponse(responseCode = "200", description = "Успешно получен список товаров")
    public Page<Product> list(
            @Parameter(description = "Поиск по названию или SKU") @RequestParam(value = "q", required = false) String q,
            @Parameter(description = "Фильтр по ID категории") @RequestParam(value = "categoryId", required = false) Long categoryId,
            @PageableDefault(size = 20, sort = "name") Pageable pageable
    ) {
        return productService.searchProducts(q, categoryId, pageable);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Получить товар по ID", description = "Возвращает информацию о конкретном товаре")
    @ApiResponse(responseCode = "200", description = "Товар найден")
    @ApiResponse(responseCode = "404", description = "Товар не найден")
    public Product getOne(@Parameter(description = "ID товара") @PathVariable Long id) {
        return productService.getOne(id);
    }

    @PostMapping
    @Operation(summary = "Создать новый товар", description = "Добавляет новый товар в систему")
    @ApiResponse(responseCode = "200", description = "Товар создан")
    @ApiResponse(responseCode = "400", description = "Ошибка валидации")
    public Product create(@Valid @RequestBody ProductDto dto, Authentication authentication) {
        Long userId = Long.parseLong(authentication.getName());
        return productService.create(dto, userId);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Обновить товар", description = "Обновляет информацию о существующем товаре")
    @ApiResponse(responseCode = "200", description = "Товар обновлен")
    @ApiResponse(responseCode = "400", description = "Ошибка валидации")
    @ApiResponse(responseCode = "404", description = "Товар не найден")
    public Product update(@PathVariable Long id, @Valid @RequestBody ProductDto dto, Authentication authentication) {
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

