package org.ngcvfb.inventorymanagementapi.controller;


import jakarta.servlet.http.HttpServletResponse;
import org.ngcvfb.inventorymanagementapi.dto.ImportMode;
import org.ngcvfb.inventorymanagementapi.dto.ImportReport;
import org.ngcvfb.inventorymanagementapi.service.ProductExportService;
import org.ngcvfb.inventorymanagementapi.service.ProductImportService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/products")
public class ImportExportController {

    private final ProductExportService exportService;
    private final ProductImportService importService;

    public ImportExportController(ProductExportService exportService, ProductImportService importService) {
        this.exportService = exportService;
        this.importService = importService;
    }


    @GetMapping("/export")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public void exportProducts(
            @RequestParam(value = "q", required = false) String q,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "size", defaultValue = "500") int size,
            HttpServletResponse response
    ) throws Exception {
        Pageable pageable = PageRequest.of(page, size);
        exportService.exportToXlsx(response, q, pageable);
    }

    @PostMapping(value = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('ADMIN')")
    public ImportReport importProducts(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "mode", defaultValue = "UPSERT") ImportMode mode
    ) throws Exception {
        return importService.importFromExcel(file, mode);
    }

}
