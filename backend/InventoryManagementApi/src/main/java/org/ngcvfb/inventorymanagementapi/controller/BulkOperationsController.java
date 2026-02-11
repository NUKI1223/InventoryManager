package org.ngcvfb.inventorymanagementapi.controller;

import org.ngcvfb.inventorymanagementapi.dto.BulkPriceUpdateRequest;
import org.ngcvfb.inventorymanagementapi.dto.BulkStockAdjustRequest;
import org.ngcvfb.inventorymanagementapi.service.ProductService;
import org.ngcvfb.inventorymanagementapi.service.StockService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bulk")
public class BulkOperationsController {
    private static final Logger log = LoggerFactory.getLogger(BulkOperationsController.class);

    private final ProductService productService;
    private final StockService stockService;

    public BulkOperationsController(ProductService productService, StockService stockService) {
        this.productService = productService;
        this.stockService = stockService;
    }

    @PostMapping("/delete")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> bulkDelete(
            @RequestBody List<Long> productIds,
            Authentication authentication
    ) {
        Long userId = Long.parseLong(authentication.getName());
        log.info("Bulk delete requested for {} products by user {}", productIds.size(), userId);

        productService.bulkDelete(productIds, userId);

        Map<String, Object> response = new HashMap<>();
        response.put("deleted", productIds.size());
        response.put("message", "Products deleted successfully");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/update-price")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> bulkUpdatePrice(
            @RequestBody BulkPriceUpdateRequest request,
            Authentication authentication
    ) {
        Long userId = Long.parseLong(authentication.getName());
        log.info("Bulk price update requested for {} products by user {}", request.getProductIds().size(), userId);

        int updated = productService.bulkUpdatePrice(request.getProductIds(), request.getNewPrice(), userId);

        Map<String, Object> response = new HashMap<>();
        response.put("updated", updated);
        response.put("message", "Prices updated successfully");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/adjust-stock")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> bulkAdjustStock(
            @RequestBody BulkStockAdjustRequest request,
            Authentication authentication
    ) {
        Long userId = Long.parseLong(authentication.getName());
        log.info("Bulk stock adjustment requested for {} products by user {}", request.getProductIds().size(), userId);

        int adjusted = stockService.bulkAdjustStock(
                request.getProductIds(),
                request.getChangeAmount(),
                request.getType(),
                request.getReference(),
                request.getNote(),
                userId
        );

        Map<String, Object> response = new HashMap<>();
        response.put("adjusted", adjusted);
        response.put("total", request.getProductIds().size());
        response.put("message", "Stock adjusted successfully");

        return ResponseEntity.ok(response);
    }
}
