package org.ngcvfb.inventorymanagementapi.controller;

import org.ngcvfb.inventorymanagementapi.repository.ProductChangeRepository;
import org.ngcvfb.inventorymanagementapi.service.ProductService;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class StatsController {
    private final ProductService productService;
    private final ProductChangeRepository changeRepo;

    public StatsController(ProductService productService, ProductChangeRepository changeRepo) {
        this.productService = productService;
        this.changeRepo = changeRepo;
    }

    @GetMapping("/stats")
    public Map<String, Object> stats(@RequestParam(required = false) String productIds) {
        // If productIds parameter exists, filter by those products
        if (productIds != null && !productIds.isEmpty()) {
            List<Long> ids = Arrays.stream(productIds.split(","))
                    .map(String::trim)
                    .map(Long::parseLong)
                    .collect(Collectors.toList());

            return getStatsForProducts(ids);
        }

        // Otherwise return stats for all products
        Long totalProducts = productService.countAllProducts();
        Long totalStock = productService.sumAllStock();
        BigDecimal totalValue = productService.totalInventoryValue();
        Long recentChanges = changeRepo.count();

        return Map.of(
                "totalProducts", totalProducts,
                "totalStock", totalStock,
                "totalInventoryValue", totalValue,
                "totalChanges", recentChanges
        );
    }

    private Map<String, Object> getStatsForProducts(List<Long> productIds) {
        Long totalProducts = productService.countProductsByIds(productIds);
        Long totalStock = productService.sumStockByIds(productIds);
        BigDecimal totalValue = productService.totalInventoryValueByIds(productIds);
        Long recentChanges = changeRepo.countByProductIdIn(productIds);

        return Map.of(
                "totalProducts", totalProducts,
                "totalStock", totalStock,
                "totalInventoryValue", totalValue,
                "totalChanges", recentChanges
        );
    }
}
