package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.dto.AdjustStockRequest;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.model.StockTransaction;
import org.ngcvfb.inventorymanagementapi.model.User;
import org.ngcvfb.inventorymanagementapi.repository.ProductRepository;
import org.ngcvfb.inventorymanagementapi.repository.StockTransactionRepository;
import org.ngcvfb.inventorymanagementapi.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

@Service
public class StockService {
    private final ProductRepository productRepo;
    private final StockTransactionRepository stockTxRepo;
    private final UserRepository userRepo;

    public StockService(ProductRepository productRepo,
                        StockTransactionRepository stockTxRepo,
                        UserRepository userRepo) {
        this.productRepo = productRepo;
        this.stockTxRepo = stockTxRepo;
        this.userRepo = userRepo;
    }

    @Transactional
    public Product adjustStock(Long productId, AdjustStockRequest req, Long userId) {
        Product p = productRepo.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        long newStock = p.getCurrentStock() + req.getChangeAmount();
        if (newStock < 0) {
            throw new RuntimeException("Insufficient stock");
        }
        p.setCurrentStock(newStock);
        productRepo.save(p);

        User u = userRepo.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        StockTransaction tx = new StockTransaction();
        tx.setProduct(p);
        tx.setChangeAmount(req.getChangeAmount());
        tx.setType(req.getType());
        tx.setReference(req.getReference());
        tx.setNote(req.getNote());
        tx.setCreatedBy(u);
        stockTxRepo.save(tx);

        return p;
    }

    public Page<StockTransaction> getTransactions(Long productId, int page, int size) {
        return stockTxRepo.findByProductId(productId, PageRequest.of(page, size));
    }
}

