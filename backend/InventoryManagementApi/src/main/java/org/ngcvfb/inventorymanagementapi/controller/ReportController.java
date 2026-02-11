package org.ngcvfb.inventorymanagementapi.controller;

import jakarta.servlet.http.HttpServletResponse;
import org.ngcvfb.inventorymanagementapi.service.ReportService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@RequestMapping("/api/reports")
public class ReportController {
    private static final Logger log = LoggerFactory.getLogger(ReportController.class);

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/products")
    @PreAuthorize("hasRole('ADMIN')")
    public void generateProductsReport(HttpServletResponse response) throws IOException {
        log.info("Products report requested");
        reportService.generateProductsReport(response);
    }

    @GetMapping("/transactions")
    @PreAuthorize("hasRole('ADMIN')")
    public void generateTransactionsReport(HttpServletResponse response) throws IOException {
        log.info("Transactions report requested");
        reportService.generateTransactionsReport(response);
    }

    @GetMapping("/low-stock")
    @PreAuthorize("hasRole('ADMIN')")
    public void generateLowStockReport(
            HttpServletResponse response,
            @RequestParam(defaultValue = "10") int threshold
    ) throws IOException {
        log.info("Low stock report requested with threshold: {}", threshold);
        reportService.generateLowStockReport(response, threshold);
    }
}
