package org.ngcvfb.inventorymanagementapi.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.ngcvfb.inventorymanagementapi.dto.ProductDto;
import org.ngcvfb.inventorymanagementapi.model.Category;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.repository.CategoryRepository;
import org.ngcvfb.inventorymanagementapi.repository.ProductRepository;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceSimpleTest {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private AuditService auditService;

    @InjectMocks
    private ProductService productService;

    private Category testCategory;
    private Product testProduct;
    private ProductDto testProductDto;

    @BeforeEach
    void setUp() {
        testCategory = new Category();
        testCategory.setId(1L);
        testCategory.setName("Electronics");

        testProduct = new Product();
        testProduct.setId(1L);
        testProduct.setSku("TEST-001");
        testProduct.setName("Test Product");
        testProduct.setPrice(new BigDecimal("99.99"));
        testProduct.setCurrentStock(100L);
        testProduct.setCategory(testCategory);

        testProductDto = new ProductDto();
        testProductDto.setSku("TEST-001");
        testProductDto.setName("Test Product");
        testProductDto.setPrice(new BigDecimal("99.99"));
        testProductDto.setCurrentStock(100L);
        testProductDto.setCategoryId(1L);
    }

    @Test
    void testGetOne_Success() {
        // Arrange
        when(productRepository.findById(1L)).thenReturn(Optional.of(testProduct));

        // Act
        Product result = productService.getOne(1L);

        // Assert
        assertNotNull(result);
        assertEquals("TEST-001", result.getSku());
        verify(productRepository, times(1)).findById(1L);
    }

    @Test
    void testGetOne_NotFound() {
        // Arrange
        when(productRepository.findById(999L)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(RuntimeException.class, () -> productService.getOne(999L));
    }

    @Test
    void testCreate_Success() {
        // Arrange
        when(categoryRepository.findById(1L)).thenReturn(Optional.of(testCategory));
        when(productRepository.save(any(Product.class))).thenReturn(testProduct);

        // Act
        Product result = productService.create(testProductDto, 1L);

        // Assert
        assertNotNull(result);
        verify(categoryRepository, times(1)).findById(1L);
        verify(productRepository, times(1)).save(any(Product.class));
    }

    @Test
    void testSave() {
        // Arrange
        when(productRepository.save(any(Product.class))).thenReturn(testProduct);

        // Act
        Product result = productService.save(testProduct);

        // Assert
        assertNotNull(result);
        assertEquals("TEST-001", result.getSku());
        verify(productRepository, times(1)).save(testProduct);
    }
}
