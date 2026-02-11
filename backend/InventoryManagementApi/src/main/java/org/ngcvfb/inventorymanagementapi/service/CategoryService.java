package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.model.Category;
import org.ngcvfb.inventorymanagementapi.repository.CategoryRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class CategoryService {
    private static final Logger log = LoggerFactory.getLogger(CategoryService.class);

    private final CategoryRepository categoryRepo;

    public CategoryService(CategoryRepository categoryRepo) {
        this.categoryRepo = categoryRepo;
    }

    public List<Category> findAll() {
        return categoryRepo.findAll();
    }

    public Category findById(Long id) {
        return categoryRepo.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));
    }

    public Category create(Category category) {
        log.info("Creating category: {}", category.getName());
        categoryRepo.findByName(category.getName()).ifPresent(c -> {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Category with this name already exists");
        });
        Category saved = categoryRepo.save(category);
        log.info("Category created with ID: {}", saved.getId());
        return saved;
    }

    public Category update(Long id, Category updated) {
        log.info("Updating category ID: {}", id);
        Category existing = findById(id);
        existing.setName(updated.getName());
        existing.setDescription(updated.getDescription());
        return categoryRepo.save(existing);
    }

    public void delete(Long id) {
        log.info("Deleting category ID: {}", id);
        Category category = findById(id);
        categoryRepo.delete(category);
        log.info("Category deleted: {}", category.getName());
    }
}
