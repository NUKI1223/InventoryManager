package org.ngcvfb.inventorymanagementapi.service;

import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.ngcvfb.inventorymanagementapi.dto.ImportMode;
import org.ngcvfb.inventorymanagementapi.dto.ImportReport;
import org.ngcvfb.inventorymanagementapi.dto.RowError;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.repository.ProductRepository;
import org.ngcvfb.inventorymanagementapi.utils.ExcelHelper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class ProductImportService {
    private final ProductRepository productRepository;
    private final ProductService productService;

    public ProductImportService(ProductRepository productRepository, ProductService productService) {
        this.productRepository = productRepository;
        this.productService = productService;
    }


    @Transactional
    public ImportReport importFromExcel(MultipartFile file, ImportMode mode) throws Exception {
        List<RowError> errors = new ArrayList<>();
        int imported = 0;
        int updated = 0;

        try (InputStream in = file.getInputStream(); Workbook wb = WorkbookFactory.create(in)) {
            Sheet sheet = wb.getSheetAt(0);
            boolean firstRow = true;
            for (Row row : sheet) {
                if (firstRow) { firstRow = false; continue; }
                final int rowNum = row.getRowNum() + 1;
                try {
                    // 0:id (опционально), 1:sku, 2:name, 3:description, 4:price, 5:currentStock, 6:imagePath
                    String sku = ExcelHelper.getString(row.getCell(1));
                    String name = ExcelHelper.getString(row.getCell(2));
                    String description = ExcelHelper.getString(row.getCell(3));
                    Double priceD = ExcelHelper.getDouble(row.getCell(4));
                    Long stockL = ExcelHelper.getLong(row.getCell(5));


                    if (sku == null || sku.trim().isEmpty()) throw new IllegalArgumentException("SKU is required");
                    if (name == null || name.trim().isEmpty()) throw new IllegalArgumentException("Name is required");

                    BigDecimal price = priceD == null ? BigDecimal.ZERO : BigDecimal.valueOf(priceD);
                    long currentStock = stockL == null ? 0L : stockL;

                    Optional<Product> existingOpt = productRepository.findBySku(sku);

                    if (existingOpt.isPresent()) {
                        if (mode == ImportMode.CREATE_ONLY) {
                            throw new IllegalArgumentException("SKU already exists and mode=createOnly");
                        }

                        Product existing = existingOpt.get();
                        updated = getImported(updated, name, description, price, currentStock, existing);
                    } else {

                        Product p = new Product();
                        p.setSku(sku);
                        imported = getImported(imported, name, description, price, currentStock, p);
                    }

                } catch (Exception ex) {
                    errors.add(new RowError(rowNum, ex.getMessage()));
                }
            }
        }

        return new ImportReport(imported, updated, errors);
    }

    private int getImported(int imported, String name, String description, BigDecimal price, long currentStock, Product p) {
        p.setName(name);
        p.setDescription(description);
        p.setPrice(price);
        p.setCurrentStock(currentStock);
        productRepository.save(p);
        imported++;
        return imported;
    }

}
