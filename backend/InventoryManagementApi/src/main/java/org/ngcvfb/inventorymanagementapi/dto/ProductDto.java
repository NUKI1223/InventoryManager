package org.ngcvfb.inventorymanagementapi.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;

public class ProductDto {
    private Long id;

    @NotBlank(message = "SKU не может быть пустым")
    @Size(min = 3, max = 50, message = "SKU должен быть от 3 до 50 символов")
    private String sku;

    @NotBlank(message = "Название не может быть пустым")
    @Size(min = 2, max = 200, message = "Название должно быть от 2 до 200 символов")
    private String name;

    @Size(max = 1000, message = "Описание не может быть длиннее 1000 символов")
    private String description;

    @NotNull(message = "Цена обязательна")
    @DecimalMin(value = "0.0", inclusive = false, message = "Цена должна быть больше 0")
    @Digits(integer = 10, fraction = 2, message = "Цена должна иметь максимум 10 цифр и 2 знака после запятой")
    private BigDecimal price;

    @NotNull(message = "Количество на складе обязательно")
    @Min(value = 0, message = "Количество не может быть отрицательным")
    private Long currentStock;

    private Long categoryId;

    // геттеры / сеттеры
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public Long getCurrentStock() { return currentStock; }
    public void setCurrentStock(Long currentStock) { this.currentStock = currentStock; }

    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }
}

