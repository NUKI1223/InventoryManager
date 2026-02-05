package org.ngcvfb.inventorymanagementapi.repository;

import org.ngcvfb.inventorymanagementapi.model.ProductChange;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductChangeRepository extends JpaRepository<ProductChange, Long> {
    Page<ProductChange> findByProductId(Long productId, Pageable pageable);
    Page<ProductChange> findByAction(String action, Pageable pageable);
    Page<ProductChange> findByProductIdAndAction(Long productId, String action, Pageable pageable);
    Long countByProductIdIn(List<Long> productIds);
}

