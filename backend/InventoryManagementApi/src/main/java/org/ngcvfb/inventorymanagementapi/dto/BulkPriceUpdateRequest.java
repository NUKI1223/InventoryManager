package org.ngcvfb.inventorymanagementapi.dto;

import java.math.BigDecimal;
import java.util.List;

public class BulkPriceUpdateRequest {
    private List<Long> productIds;
    private BigDecimal newPrice;

    public List<Long> getProductIds() {
        return productIds;
    }

    public void setProductIds(List<Long> productIds) {
        this.productIds = productIds;
    }

    public BigDecimal getNewPrice() {
        return newPrice;
    }

    public void setNewPrice(BigDecimal newPrice) {
        this.newPrice = newPrice;
    }
}
