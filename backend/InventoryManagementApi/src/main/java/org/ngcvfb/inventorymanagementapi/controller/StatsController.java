package org.ngcvfb.inventorymanagementapi.controller;

import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.model.StockTransaction;
import org.ngcvfb.inventorymanagementapi.repository.ProductChangeRepository;
import org.ngcvfb.inventorymanagementapi.repository.ProductRepository;
import org.ngcvfb.inventorymanagementapi.repository.StockTransactionRepository;
import org.ngcvfb.inventorymanagementapi.service.ProductService;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.*;
import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class StatsController {
    private final ProductService productService;
    private final ProductChangeRepository changeRepo;
    private final ProductRepository productRepo;
    private final StockTransactionRepository stockTransactionRepo;

    public StatsController(ProductService productService, ProductChangeRepository changeRepo,
                          ProductRepository productRepo, StockTransactionRepository stockTransactionRepo) {
        this.productService = productService;
        this.changeRepo = changeRepo;
        this.productRepo = productRepo;
        this.stockTransactionRepo = stockTransactionRepo;
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

    @GetMapping("/products/low-stock")
    public List<Product> getLowStockProducts(@RequestParam(defaultValue = "5") int threshold) {
        return productRepo.findAll().stream()
                .filter(p -> p.getCurrentStock() != null && p.getCurrentStock() <= threshold)
                .limit(20)
                .collect(Collectors.toList());
    }

    @GetMapping("/products/zero-stock")
    public List<Product> getZeroStockProducts() {
        return productRepo.findAll().stream()
                .filter(p -> p.getCurrentStock() != null && p.getCurrentStock() == 0)
                .limit(20)
                .collect(Collectors.toList());
    }

    @GetMapping("/stats/recent-transactions")
    public List<StockTransaction> getRecentTransactions(@RequestParam(defaultValue = "10") int limit) {
        return stockTransactionRepo.findAll(PageRequest.of(0, limit)).getContent();
    }

    @GetMapping("/stats/by-category")
    public List<Map<String, Object>> getStatsByCategory() {
        List<Product> products = productRepo.findAll();
        Map<String, List<Product>> byCategory = products.stream()
                .collect(Collectors.groupingBy(p ->
                    p.getCategory() != null ? p.getCategory().getName() : "No Category"
                ));

        return byCategory.entrySet().stream()
                .map(entry -> {
                    List<Product> catProducts = entry.getValue();
                    long totalStock = catProducts.stream()
                            .mapToLong(p -> p.getCurrentStock() != null ? p.getCurrentStock() : 0)
                            .sum();
                    double totalValue = catProducts.stream()
                            .mapToDouble(p -> {
                                if (p.getPrice() != null && p.getCurrentStock() != null) {
                                    return p.getPrice().doubleValue() * p.getCurrentStock();
                                }
                                return 0;
                            })
                            .sum();

                    Map<String, Object> result = new HashMap<>();
                    result.put("category", entry.getKey());
                    result.put("productCount", catProducts.size());
                    result.put("totalStock", totalStock);
                    result.put("totalValue", totalValue);
                    return result;
                })
                .collect(Collectors.toList());
    }
}
