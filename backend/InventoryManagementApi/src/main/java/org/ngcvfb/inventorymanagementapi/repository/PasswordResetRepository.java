package org.ngcvfb.inventorymanagementapi.repository;

import org.ngcvfb.inventorymanagementapi.model.PasswordResetRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PasswordResetRepository extends JpaRepository<PasswordResetRequest, Long> {
    List<PasswordResetRequest> findByStatusOrderByRequestedAtDesc(String status);
}

