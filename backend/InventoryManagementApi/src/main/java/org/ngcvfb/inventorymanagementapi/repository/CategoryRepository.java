package org.ngcvfb.inventorymanagementapi.repository;

import org.ngcvfb.inventorymanagementapi.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    Optional<Category> findByName(String name);
}
