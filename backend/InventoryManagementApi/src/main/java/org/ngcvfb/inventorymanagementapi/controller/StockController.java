package org.ngcvfb.inventorymanagementapi.controller;

import org.ngcvfb.inventorymanagementapi.config.JwtUtil;
import org.ngcvfb.inventorymanagementapi.dto.AdjustStockRequest;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.model.StockTransaction;
import org.ngcvfb.inventorymanagementapi.service.StockService;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/products/{productId}/stock")
public class StockController {
    private final StockService stockService;
    private final JwtUtil jwtUtil;

    public StockController(StockService stockService, JwtUtil jwtUtil) {
        this.stockService = stockService;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/adjust")
    public Product adjust(@PathVariable Long productId,
                          @RequestBody AdjustStockRequest req,
                          @RequestHeader("Authorization") String auth) {
        String token = auth.substring(7);
        Long userId = jwtUtil.getUserId(token);
        return stockService.adjustStock(productId, req, userId);
    }

    @GetMapping("/transactions")
    public Page<StockTransaction> transactions(@PathVariable Long productId,
                                               @RequestParam(defaultValue = "0") int page,
                                               @RequestParam(defaultValue = "20") int size) {
        return stockService.getTransactions(productId, page, size);
    }
}

