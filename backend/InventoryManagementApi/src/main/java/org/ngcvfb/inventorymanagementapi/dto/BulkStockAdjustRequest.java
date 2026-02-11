package org.ngcvfb.inventorymanagementapi.dto;

import java.util.List;

public class BulkStockAdjustRequest {
    private List<Long> productIds;
    private Long changeAmount;
    private String type;
    private String reference;
    private String note;

    // Getters and Setters
    public List<Long> getProductIds() {
        return productIds;
    }

    public void setProductIds(List<Long> productIds) {
        this.productIds = productIds;
    }

    public Long getChangeAmount() {
        return changeAmount;
    }

    public void setChangeAmount(Long changeAmount) {
        this.changeAmount = changeAmount;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getReference() {
        return reference;
    }

    public void setReference(String reference) {
        this.reference = reference;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
