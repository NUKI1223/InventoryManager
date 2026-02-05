package org.ngcvfb.inventorymanagementapi.controller;

import org.ngcvfb.inventorymanagementapi.model.ProductChange;
import org.ngcvfb.inventorymanagementapi.repository.ProductChangeRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class HistoryController {
    private final ProductChangeRepository repo;

    public HistoryController(ProductChangeRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/history")
    public Page<ProductChange> history(
            @RequestParam(value = "productId", required = false) Long productId,
            @RequestParam(value = "action", required = false) String action,
            Pageable pageable
    ) {
        if (productId != null && action != null) {
            return repo.findByProductIdAndAction(productId, action, pageable);
        } else if (productId != null) {
            return repo.findByProductId(productId, pageable);
        } else if (action != null) {
            return repo.findByAction(action, pageable);
        }
        return repo.findAll(pageable);
    }
}

