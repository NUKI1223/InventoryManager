package org.ngcvfb.inventorymanagementapi.model;

import jakarta.persistence.*;
import java.time.OffsetDateTime;

@Entity
@Table(name = "product_changes")
public class ProductChange {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long productId;

    private String action; // CREATE, UPDATE, DELETE, UPLOAD_IMAGE, ADJUST_STOCK

    private Long performedBy; // user id (nullable)

    private OffsetDateTime createdAt;

    @Column(columnDefinition = "text")
    private String details; // any JSON/text details

    public ProductChange() {}

    public ProductChange(Long productId, String action, Long performedBy, OffsetDateTime createdAt, String details) {
        this.productId = productId;
        this.action = action;
        this.performedBy = performedBy;
        this.createdAt = createdAt;
        this.details = details;
    }

    // getters / setters
    public Long getId() { return id; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public Long getPerformedBy() { return performedBy; }
    public void setPerformedBy(Long performedBy) { this.performedBy = performedBy; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }
}

