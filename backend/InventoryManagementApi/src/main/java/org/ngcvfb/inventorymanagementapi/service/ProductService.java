package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.dto.ProductDto;
import org.ngcvfb.inventorymanagementapi.model.Category;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.repository.CategoryRepository;
import org.ngcvfb.inventorymanagementapi.repository.ProductRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ProductService {
    private final ProductRepository productRepo;
    private final CategoryRepository categoryRepo;
    private final AuditService auditService;

    public ProductService(ProductRepository productRepo, CategoryRepository categoryRepo, AuditService auditService) {
        this.productRepo = productRepo;
        this.categoryRepo = categoryRepo;
        this.auditService = auditService;
    }

    public Page<Product> list(int page, int size) {
        return productRepo.findAll(PageRequest.of(page, size));
    }

    public Product getOne(Long id) {
        return productRepo.findById(id).orElseThrow(() -> new RuntimeException("Not found"));
    }

    public Product create(ProductDto dto, Long performedBy) {
        Product p = new Product();
        p.setSku(dto.getSku());
        p.setName(dto.getName());
        p.setDescription(dto.getDescription());
        p.setPrice(dto.getPrice());
        p.setCurrentStock(dto.getCurrentStock());
        if (dto.getCategoryId() != null) {
            Category cat = categoryRepo.findById(dto.getCategoryId()).orElse(null);
            p.setCategory(cat);
        }
        Product saved = productRepo.save(p);
        Map<String, Object> details = new HashMap<>();
        details.put("name", saved.getName());
        details.put("sku", saved.getSku());
        auditService.record(saved.getId(), "CREATE", performedBy, details);
        return saved;
    }

    @Transactional
    public Product update(Long id, ProductDto dto, Long performedBy) {
        Product existing = getOne(id);
        existing.setName(dto.getName());
        existing.setSku(dto.getSku());
        existing.setDescription(dto.getDescription());
        existing.setPrice(dto.getPrice());
        existing.setCurrentStock(dto.getCurrentStock());
        if (dto.getCategoryId() != null) {
            Category cat = categoryRepo.findById(dto.getCategoryId()).orElse(null);
            existing.setCategory(cat);
        } else {
            existing.setCategory(null);
        }
        Product saved = productRepo.save(existing);

        Map<String, Object> details = new HashMap<>();
        details.put("name", saved.getName());
        details.put("sku", saved.getSku());
        auditService.record(saved.getId(), "UPDATE", performedBy, details);

        return saved;
    }

    public Product save(Product p) {
        return productRepo.save(p);
    }

    @Transactional
    public void softDelete(Long id, Long performedBy) {
        Product p = getOne(id);
        productRepo.delete(p);
        Map<String, Object> details = new HashMap<>();
        details.put("name", p.getName());
        details.put("sku", p.getSku());
        auditService.record(p.getId(), "DELETE", performedBy, details);
    }

    public Page<Product> searchProducts(String q, Long categoryId, Pageable pageable) {
        boolean hasQ = q != null && !q.trim().isEmpty();
        boolean hasCat = categoryId != null;

        if (hasQ && hasCat) {
            return productRepo.searchByQAndCategory(q.trim(), categoryId, pageable);
        } else if (hasQ) {
            return productRepo.searchByQ(q.trim(), pageable);
        } else if (hasCat) {
            return productRepo.findByCategoryId(categoryId, pageable);
        } else {
            return productRepo.findAll(pageable);
        }
    }

    public Long countAllProducts() {
        return productRepo.count();
    }

    public Long sumAllStock() {
        Long res = productRepo.sumCurrentStock();
        return res == null ? 0L : res;
    }

    public BigDecimal totalInventoryValue() {
        BigDecimal res = productRepo.sumPriceTimesStock();
        return res == null ? BigDecimal.ZERO : res;
    }

    public Long countProductsByIds(List<Long> productIds) {
        return (long) productRepo.findAllById(productIds).size();
    }

    public Long sumStockByIds(List<Long> productIds) {
        Long res = productRepo.sumCurrentStockByIds(productIds);
        return res == null ? 0L : res;
    }

    public BigDecimal totalInventoryValueByIds(List<Long> productIds) {
        BigDecimal res = productRepo.sumPriceTimesStockByIds(productIds);
        return res == null ? BigDecimal.ZERO : res;
    }

    @Transactional
    public void bulkDelete(List<Long> productIds, Long performedBy) {
        List<Product> products = productRepo.findAllById(productIds);
        for (Product p : products) {
            Map<String, Object> details = new HashMap<>();
            details.put("name", p.getName());
            details.put("sku", p.getSku());
            auditService.record(p.getId(), "BULK_DELETE", performedBy, details);
        }
        productRepo.deleteAllById(productIds);
    }

    @Transactional
    public int bulkUpdatePrice(List<Long> productIds, BigDecimal newPrice, Long performedBy) {
        List<Product> products = productRepo.findAllById(productIds);
        for (Product p : products) {
            Map<String, Object> details = new HashMap<>();
            details.put("oldPrice", p.getPrice());
            details.put("newPrice", newPrice);
            p.setPrice(newPrice);
            productRepo.save(p);
            auditService.record(p.getId(), "BULK_PRICE_UPDATE", performedBy, details);
        }
        return products.size();
    }
}

