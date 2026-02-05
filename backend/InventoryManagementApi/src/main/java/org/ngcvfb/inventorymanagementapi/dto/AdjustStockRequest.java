package org.ngcvfb.inventorymanagementapi.dto;

public class AdjustStockRequest {
    private Long changeAmount;
    private String type;
    private String reference;
    private String note;

    public Long getChangeAmount() { return changeAmount; }
    public void setChangeAmount(Long changeAmount) { this.changeAmount = changeAmount; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
