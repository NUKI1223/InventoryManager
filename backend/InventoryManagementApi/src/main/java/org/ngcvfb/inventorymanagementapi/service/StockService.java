package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.dto.AdjustStockRequest;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.model.StockTransaction;
import org.ngcvfb.inventorymanagementapi.model.User;
import org.ngcvfb.inventorymanagementapi.repository.ProductRepository;
import org.ngcvfb.inventorymanagementapi.repository.StockTransactionRepository;
import org.ngcvfb.inventorymanagementapi.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;

@Service
public class StockService {
    private static final Logger log = LoggerFactory.getLogger(StockService.class);
    private static final int LOW_STOCK_THRESHOLD = 5;

    private final ProductRepository productRepo;
    private final StockTransactionRepository stockTxRepo;
    private final UserRepository userRepo;
    private final NotificationService notificationService;

    public StockService(ProductRepository productRepo,
                        StockTransactionRepository stockTxRepo,
                        UserRepository userRepo,
                        NotificationService notificationService) {
        this.productRepo = productRepo;
        this.stockTxRepo = stockTxRepo;
        this.userRepo = userRepo;
        this.notificationService = notificationService;
    }

    @Transactional
    public Product adjustStock(Long productId, AdjustStockRequest req, Long userId) {
        log.info("Adjusting stock for product ID: {}, change: {}, type: {}", productId, req.getChangeAmount(), req.getType());

        Product p = productRepo.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found"));
        long oldStock = p.getCurrentStock();
        long newStock = oldStock + req.getChangeAmount();

        if (newStock < 0) {
            log.error("Insufficient stock for product ID: {}. Current: {}, requested change: {}", productId, oldStock, req.getChangeAmount());
            throw new RuntimeException("Insufficient stock");
        }

        p.setCurrentStock(newStock);
        productRepo.save(p);
        log.debug("Stock updated for product ID: {}. Old: {}, New: {}", productId, oldStock, newStock);

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

        log.info("Stock transaction saved for product ID: {}", productId);

        // Check if stock is low and create notifications
        if (newStock > 0 && newStock <= LOW_STOCK_THRESHOLD && oldStock > LOW_STOCK_THRESHOLD) {
            log.warn("Low stock detected for product ID: {}. Creating notifications for admins.", productId);
            notificationService.notifyAllAdminsLowStock(p);
        }

        return p;
    }

    public Page<StockTransaction> getTransactions(Long productId, int page, int size) {
        return stockTxRepo.findByProductId(productId, PageRequest.of(page, size));
    }
}

