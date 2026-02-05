package org.ngcvfb.inventorymanagementapi.dto;

import java.util.List;

public class ImportReport {
    private int imported;
    private int updated;
    private List<RowError> errors;

    public ImportReport() {}

    public ImportReport(int imported, int updated, List<RowError> errors) {
        this.imported = imported;
        this.updated = updated;
        this.errors = errors;
    }

    public int getImported() { return imported; }
    public void setImported(int imported) { this.imported = imported; }

    public int getUpdated() { return updated; }
    public void setUpdated(int updated) { this.updated = updated; }

    public List<RowError> getErrors() { return errors; }
    public void setErrors(List<RowError> errors) { this.errors = errors; }
}
