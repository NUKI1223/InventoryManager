package org.ngcvfb.inventorymanagementapi.repository;

import org.ngcvfb.inventorymanagementapi.model.StockTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface StockTransactionRepository extends JpaRepository<StockTransaction, Long> {
    Page<StockTransaction> findByProductId(Long productId, Pageable pageable);
    Page<StockTransaction> findAllByOrderByCreatedAtDesc(Pageable pageable);

    void deleteByProductId(Long productId);
}
