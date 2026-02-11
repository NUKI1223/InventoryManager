package org.ngcvfb.inventorymanagementapi.service;

import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class ProductExportService {
    private final ProductService productService;

    public ProductExportService(ProductService productService) {
        this.productService = productService;
    }


    public void exportToXlsx(HttpServletResponse response, String q, Pageable pageable) throws IOException {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String fileName = "products_" + System.currentTimeMillis() + ".xlsx";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (SXSSFWorkbook wb = new SXSSFWorkbook(100)) {
            Sheet sheet = wb.createSheet("Products");
            Row header = sheet.createRow(0);
            header.createCell(0).setCellValue("id");
            header.createCell(1).setCellValue("sku");
            header.createCell(2).setCellValue("name");
            header.createCell(3).setCellValue("description");
            header.createCell(4).setCellValue("price");
            header.createCell(5).setCellValue("currentStock");

            int rowIndex = 1;
            Page<Product> page = productService.searchProducts(q, null, pageable);
            while (true) {
                for (Product p : page.getContent()) {
                    Row r = sheet.createRow(rowIndex++);
                    r.createCell(0).setCellValue(p.getId());
                    r.createCell(1).setCellValue(p.getSku());
                    r.createCell(2).setCellValue(p.getName());
                    r.createCell(3).setCellValue(p.getDescription() == null ? "" : p.getDescription());
                    r.createCell(4).setCellValue(p.getPrice() != null ? p.getPrice().doubleValue() : 0.0);
                    r.createCell(5).setCellValue(p.getCurrentStock() == null ? 0L : p.getCurrentStock());
                }
                if (!page.hasNext()) break;
                page = productService.searchProducts(q, null, page.nextPageable());
            }

            ServletOutputStream out = response.getOutputStream();
            wb.write(out);
            out.flush();
        }
    }
}
