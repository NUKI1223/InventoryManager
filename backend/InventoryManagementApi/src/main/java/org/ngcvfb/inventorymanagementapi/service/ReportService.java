package org.ngcvfb.inventorymanagementapi.service;

import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.model.StockTransaction;
import org.ngcvfb.inventorymanagementapi.repository.ProductRepository;
import org.ngcvfb.inventorymanagementapi.repository.StockTransactionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service
public class ReportService {
    private static final Logger log = LoggerFactory.getLogger(ReportService.class);

    private final ProductRepository productRepo;
    private final StockTransactionRepository transactionRepo;
    private final ProductService productService;

    public ReportService(ProductRepository productRepo,
                        StockTransactionRepository transactionRepo,
                        ProductService productService) {
        this.productRepo = productRepo;
        this.transactionRepo = transactionRepo;
        this.productService = productService;
    }

    public void generateProductsReport(HttpServletResponse response) throws IOException {
        log.info("Generating products report");
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String fileName = "products_report_" + System.currentTimeMillis() + ".xlsx";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (SXSSFWorkbook wb = new SXSSFWorkbook(100)) {
            Sheet sheet = wb.createSheet("Products");
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("ID");
            header.createCell(1).setCellValue("SKU");
            header.createCell(2).setCellValue("Name");
            header.createCell(3).setCellValue("Category");
            header.createCell(4).setCellValue("Price");
            header.createCell(5).setCellValue("Current Stock");
            header.createCell(6).setCellValue("Stock Value");

            int rowIndex = 1;
            Page<Product> page = productRepo.findAll(PageRequest.of(0, 100));
            while (true) {
                for (Product p : page.getContent()) {
                    Row r = sheet.createRow(rowIndex++);
                    r.createCell(0).setCellValue(p.getId());
                    r.createCell(1).setCellValue(p.getSku());
                    r.createCell(2).setCellValue(p.getName());
                    r.createCell(3).setCellValue(p.getCategory() != null ? p.getCategory().getName() : "");
                    r.createCell(4).setCellValue(p.getPrice() != null ? p.getPrice().doubleValue() : 0.0);
                    r.createCell(5).setCellValue(p.getCurrentStock() != null ? p.getCurrentStock() : 0L);
                    double stockValue = (p.getPrice() != null ? p.getPrice().doubleValue() : 0.0) *
                                       (p.getCurrentStock() != null ? p.getCurrentStock() : 0L);
                    r.createCell(6).setCellValue(stockValue);
                }
                if (!page.hasNext()) break;
                page = productRepo.findAll(page.nextPageable());
            }

            ServletOutputStream out = response.getOutputStream();
            wb.write(out);
            out.flush();
        }
    }

    public void generateTransactionsReport(HttpServletResponse response) throws IOException {
        log.info("Generating transactions report");
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String fileName = "transactions_report_" + System.currentTimeMillis() + ".xlsx";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (SXSSFWorkbook wb = new SXSSFWorkbook(100)) {
            Sheet sheet = wb.createSheet("Transactions");
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("ID");
            header.createCell(1).setCellValue("Product");
            header.createCell(2).setCellValue("Type");
            header.createCell(3).setCellValue("Change Amount");
            header.createCell(4).setCellValue("Reference");
            header.createCell(5).setCellValue("Created By");
            header.createCell(6).setCellValue("Timestamp");

            int rowIndex = 1;
            Page<StockTransaction> page = transactionRepo.findAllByOrderByCreatedAtDesc(PageRequest.of(0, 100));
            while (true) {
                for (StockTransaction tx : page.getContent()) {
                    Row r = sheet.createRow(rowIndex++);
                    r.createCell(0).setCellValue(tx.getId());
                    r.createCell(1).setCellValue(tx.getProduct() != null ? tx.getProduct().getName() : "");
                    r.createCell(2).setCellValue(tx.getType());
                    r.createCell(3).setCellValue(tx.getChangeAmount());
                    r.createCell(4).setCellValue(tx.getReference() != null ? tx.getReference() : "");
                    r.createCell(5).setCellValue(tx.getCreatedBy() != null ? tx.getCreatedBy().getUsername() : "");
                    r.createCell(6).setCellValue(tx.getCreatedAt().toString());
                }
                if (!page.hasNext()) break;
                page = transactionRepo.findAllByOrderByCreatedAtDesc(page.nextPageable());
            }

            ServletOutputStream out = response.getOutputStream();
            wb.write(out);
            out.flush();
        }
    }

    public void generateLowStockReport(HttpServletResponse response, int threshold) throws IOException {
        log.info("Generating low stock report with threshold: {}", threshold);
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String fileName = "low_stock_report_" + System.currentTimeMillis() + ".xlsx";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (SXSSFWorkbook wb = new SXSSFWorkbook(100)) {
            Sheet sheet = wb.createSheet("Low Stock Products");
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("ID");
            header.createCell(1).setCellValue("SKU");
            header.createCell(2).setCellValue("Name");
            header.createCell(3).setCellValue("Category");
            header.createCell(4).setCellValue("Current Stock");
            header.createCell(5).setCellValue("Price");

            List<Product> lowStockProducts = productRepo.findByCurrentStockLessThanOrderByCurrentStockAsc(threshold);

            int rowIndex = 1;
            for (Product p : lowStockProducts) {
                Row r = sheet.createRow(rowIndex++);
                r.createCell(0).setCellValue(p.getId());
                r.createCell(1).setCellValue(p.getSku());
                r.createCell(2).setCellValue(p.getName());
                r.createCell(3).setCellValue(p.getCategory() != null ? p.getCategory().getName() : "");
                r.createCell(4).setCellValue(p.getCurrentStock() != null ? p.getCurrentStock() : 0L);
                r.createCell(5).setCellValue(p.getPrice() != null ? p.getPrice().doubleValue() : 0.0);
            }

            ServletOutputStream out = response.getOutputStream();
            wb.write(out);
            out.flush();
        }
    }
}
