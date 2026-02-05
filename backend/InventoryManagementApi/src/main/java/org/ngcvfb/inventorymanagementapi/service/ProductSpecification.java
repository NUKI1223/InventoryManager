package org.ngcvfb.inventorymanagementapi.service;

import jakarta.persistence.criteria.Predicate;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.springframework.data.jpa.domain.Specification;

public class ProductSpecification {
    public static Specification<Product> searchByText(String q) {
        return (root, query, cb) -> {
            if (q == null || q.trim().isEmpty()) return cb.conjunction();
            String like = "%" + q.trim().toLowerCase() + "%";
            Predicate name = cb.like(cb.lower(root.get("name")), like);
            Predicate sku = cb.like(cb.lower(root.get("sku")), like);
            return cb.or(name, sku);
        };
    }
}
