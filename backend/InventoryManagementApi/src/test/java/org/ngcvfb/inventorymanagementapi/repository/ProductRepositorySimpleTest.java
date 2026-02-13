package org.ngcvfb.inventorymanagementapi.repository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.ngcvfb.inventorymanagementapi.model.Category;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
@ActiveProfiles("test")
class ProductRepositorySimpleTest {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    private Category testCategory;

    @BeforeEach
    void setUp() {
        productRepository.deleteAll();
        categoryRepository.deleteAll();

        testCategory = new Category();
        testCategory.setName("Electronics");
        testCategory = categoryRepository.save(testCategory);
    }

    @Test
    void testSaveAndFindProduct() {
        // Arrange
        Product product = new Product();
        product.setSku("TEST-001");
        product.setName("Test Product");
        product.setPrice(new BigDecimal("99.99"));
        product.setCurrentStock(100L);
        product.setCategory(testCategory);

        // Act
        Product saved = productRepository.save(product);
        Optional<Product> found = productRepository.findById(saved.getId());

        // Assert
        assertTrue(found.isPresent());
        assertEquals("TEST-001", found.get().getSku());
        assertEquals("Test Product", found.get().getName());
    }

    @Test
    void testFindBySku() {
        // Arrange
        Product product = new Product();
        product.setSku("UNIQUE-SKU");
        product.setName("Unique Product");
        product.setPrice(new BigDecimal("99.99"));
        product.setCurrentStock(100L);
        product.setCategory(testCategory);
        productRepository.save(product);

        // Act
        Optional<Product> found = productRepository.findBySku("UNIQUE-SKU");

        // Assert
        assertTrue(found.isPresent());
        assertEquals("Unique Product", found.get().getName());
    }

    @Test
    void testFindByCurrentStockLessThan() {
        // Arrange
        Product lowStock = new Product();
        lowStock.setSku("LOW-001");
        lowStock.setName("Low Stock Item");
        lowStock.setPrice(new BigDecimal("50.00"));
        lowStock.setCurrentStock(3L);
        lowStock.setCategory(testCategory);
        productRepository.save(lowStock);

        Product normalStock = new Product();
        normalStock.setSku("NORMAL-001");
        normalStock.setName("Normal Stock Item");
        normalStock.setPrice(new BigDecimal("50.00"));
        normalStock.setCurrentStock(100L);
        normalStock.setCategory(testCategory);
        productRepository.save(normalStock);

        // Act
        List<Product> result = productRepository.findByCurrentStockLessThanOrderByCurrentStockAsc(10L);

        // Assert
        assertEquals(1, result.size());
        assertEquals("LOW-001", result.get(0).getSku());
    }

    @Test
    void testDeleteProduct() {
        // Arrange
        Product product = new Product();
        product.setSku("DELETE-001");
        product.setName("To Delete");
        product.setPrice(new BigDecimal("50.00"));
        product.setCurrentStock(10L);
        product.setCategory(testCategory);
        Product saved = productRepository.save(product);

        // Act
        productRepository.deleteById(saved.getId());

        // Assert
        assertFalse(productRepository.findById(saved.getId()).isPresent());
    }

    @Test
    void testOptimisticLocking() {
        // Arrange
        Product product = new Product();
        product.setSku("VERSION-001");
        product.setName("Version Test");
        product.setPrice(new BigDecimal("100.00"));
        product.setCurrentStock(50L);
        product.setCategory(testCategory);

        // Act
        Product saved = productRepository.save(product);

        // Assert - Version starts at 0
        assertNotNull(saved.getVersion());
        assertEquals(0, saved.getVersion());

        // Update and verify version field exists
        saved.setName("Updated");
        Product updated = productRepository.save(saved);
        assertNotNull(updated.getVersion());
        assertTrue(updated.getVersion() >= 0);
    }
}
