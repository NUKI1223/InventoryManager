package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.model.ProductChange;
import org.ngcvfb.inventorymanagementapi.repository.ProductChangeRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class AuditService {
    private final ProductChangeRepository repo;
    private final ObjectMapper mapper;

    public AuditService(ProductChangeRepository repo, ObjectMapper mapper) {
        this.repo = repo;
        this.mapper = mapper;
    }

    @Transactional
    public void record(Long productId, String action, Long performedBy, Map<String, Object> details) {
        try {
            String jsonDetails = details == null ? null : mapper.writeValueAsString(details);
            ProductChange pc = new ProductChange(productId, action, performedBy, OffsetDateTime.now(), jsonDetails);
            repo.save(pc);
        } catch (Exception ex) {
            // не ломаем основную логику: логируем и продолжаем
            ex.printStackTrace();
        }
    }
}

