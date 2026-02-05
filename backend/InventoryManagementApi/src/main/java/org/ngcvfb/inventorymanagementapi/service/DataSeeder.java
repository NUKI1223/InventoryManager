package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.model.Category;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.model.User;
import org.ngcvfb.inventorymanagementapi.repository.CategoryRepository;
import org.ngcvfb.inventorymanagementapi.repository.ProductRepository;
import org.ngcvfb.inventorymanagementapi.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
public class DataSeeder implements CommandLineRunner {
    private final UserRepository userRepo;
    private final CategoryRepository categoryRepo;
    private final ProductRepository productRepo;
    private final PasswordEncoder passwordEncoder;

    public DataSeeder(UserRepository userRepo, CategoryRepository categoryRepo,
                      ProductRepository productRepo, PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.categoryRepo = categoryRepo;
        this.productRepo = productRepo;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (userRepo.count() > 0) {
            return;
        }

        // Users
        User admin = new User();
        admin.setUsername("admin");
        admin.setPasswordHash(passwordEncoder.encode("admin123"));
        admin.setFullName("Administrator");
        admin.setRole("ADMIN");
        userRepo.save(admin);

        User user = new User();
        user.setUsername("user");
        user.setPasswordHash(passwordEncoder.encode("user123"));
        user.setFullName("Regular User");
        user.setRole("USER");
        userRepo.save(user);

        // Categories
        Category electronics = createCategory("Electronics", "Electronic devices and components");
        Category furniture = createCategory("Furniture", "Office and home furniture");
        Category stationery = createCategory("Stationery", "Office supplies and stationery");
        Category tools = createCategory("Tools", "Hardware tools and equipment");
        Category food = createCategory("Food", "Food and beverages");

        // Products
        createProduct("LAPTOP-001", "Laptop Dell XPS 15", "High-performance laptop", new BigDecimal("1299.99"), 25L, electronics);
        createProduct("PHONE-001", "iPhone 15 Pro", "Apple smartphone", new BigDecimal("999.99"), 50L, electronics);
        createProduct("MONITOR-001", "Samsung 27\" Monitor", "4K UHD monitor", new BigDecimal("349.99"), 30L, electronics);
        createProduct("KEYBOARD-001", "Mechanical Keyboard", "RGB mechanical keyboard", new BigDecimal("79.99"), 100L, electronics);
        createProduct("MOUSE-001", "Wireless Mouse", "Ergonomic wireless mouse", new BigDecimal("29.99"), 150L, electronics);

        createProduct("DESK-001", "Standing Desk", "Adjustable standing desk", new BigDecimal("499.99"), 15L, furniture);
        createProduct("CHAIR-001", "Office Chair", "Ergonomic office chair", new BigDecimal("299.99"), 20L, furniture);
        createProduct("SHELF-001", "Bookshelf", "Wooden bookshelf 5-tier", new BigDecimal("89.99"), 35L, furniture);

        createProduct("PEN-001", "Ballpoint Pen Pack", "Pack of 12 pens", new BigDecimal("5.99"), 500L, stationery);
        createProduct("PAPER-001", "A4 Paper 500 sheets", "White A4 paper", new BigDecimal("7.49"), 200L, stationery);
        createProduct("NOTE-001", "Notebook A5", "Lined notebook", new BigDecimal("3.99"), 300L, stationery);

        createProduct("DRILL-001", "Power Drill", "Cordless power drill", new BigDecimal("89.99"), 40L, tools);
        createProduct("HAMMER-001", "Claw Hammer", "Steel claw hammer", new BigDecimal("19.99"), 60L, tools);

        createProduct("COFFEE-001", "Coffee Beans 1kg", "Arabica coffee beans", new BigDecimal("14.99"), 80L, food);
        createProduct("WATER-001", "Bottled Water 12-pack", "Spring water 500ml x12", new BigDecimal("6.99"), 120L, food);
    }

    private Category createCategory(String name, String description) {
        Category c = new Category();
        c.setName(name);
        c.setDescription(description);
        return categoryRepo.save(c);
    }

    private void createProduct(String sku, String name, String description, BigDecimal price, Long stock, Category category) {
        Product p = new Product();
        p.setSku(sku);
        p.setName(name);
        p.setDescription(description);
        p.setPrice(price);
        p.setCurrentStock(stock);
        p.setCategory(category);
        productRepo.save(p);
    }
}
