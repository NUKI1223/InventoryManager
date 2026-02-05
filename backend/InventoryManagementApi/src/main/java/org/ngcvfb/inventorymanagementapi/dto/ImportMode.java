package org.ngcvfb.inventorymanagementapi.dto;

public enum ImportMode {
    UPSERT,    // обновлять существующие по sku, иначе создавать
    CREATE_ONLY // только создавать (если sku уже есть — ошибка)
}