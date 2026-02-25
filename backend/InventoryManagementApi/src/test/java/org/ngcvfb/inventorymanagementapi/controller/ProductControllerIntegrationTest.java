package org.ngcvfb.inventorymanagementapi.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.ngcvfb.inventorymanagementapi.model.User;
import org.ngcvfb.inventorymanagementapi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.math.BigDecimal;
import java.util.Map;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ProductControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private String adminToken;

    @BeforeEach
    void setUp() throws Exception {
        // Создаём admin-пользователя напрямую через репозиторий
        String adminUsername = "admin_prod_" + System.currentTimeMillis();
        User admin = new User();
        admin.setUsername(adminUsername);
        admin.setPasswordHash(passwordEncoder.encode("adminpass"));
        admin.setRole("ADMIN");
        admin.setFullName("Admin Test");
        userRepository.save(admin);

        // Логинимся, получаем JWT
        Map<String, String> loginReq = Map.of("username", adminUsername, "password", "adminpass");
        MvcResult result = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        adminToken = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("token").asText();
    }

    @Test
    void getProducts_AuthenticatedUser_ReturnsPaginatedList() throws Exception {
        mockMvc.perform(get("/api/products")
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().is2xxSuccessful())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.totalElements").isNumber());
    }

    @Test
    void createProduct_ValidData_ReturnsCreatedProduct() throws Exception {
        // Arrange
        Map<String, Object> request = Map.of(
                "sku", "INT-TEST-" + System.currentTimeMillis(),
                "name", "Интеграционный Тест Товар",
                "description", "Тестовый товар",
                "price", new BigDecimal("999.99"),
                "currentStock", 50L
        );

        // Act & Assert
        mockMvc.perform(post("/api/products")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.name").value("Интеграционный Тест Товар"))
                .andExpect(jsonPath("$.currentStock").value(50));
    }

    @Test
    void createProduct_DuplicateSku_Returns409() throws Exception {
        // Arrange
        String sku = "DUPE-SKU-" + System.currentTimeMillis();
        Map<String, Object> request = Map.of(
                "sku", sku,
                "name", "Товар с дублем SKU",
                "price", new BigDecimal("100.00"),
                "currentStock", 10L
        );

        // Первый создаём успешно
        mockMvc.perform(post("/api/products")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful());

        // Второй должен вернуть 409
        mockMvc.perform(post("/api/products")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("Товар с таким артикулом уже существует"));
    }

    @Test
    void getProductById_ExistingProduct_ReturnsProduct() throws Exception {
        // Arrange — создаём товар
        Map<String, Object> request = Map.of(
                "sku", "GET-BY-ID-" + System.currentTimeMillis(),
                "name", "Товар для получения по ID",
                "price", new BigDecimal("250.00"),
                "currentStock", 20L
        );
        MvcResult created = mockMvc.perform(post("/api/products")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        Long productId = objectMapper.readTree(created.getResponse().getContentAsString())
                .get("id").asLong();

        // Act — получаем по ID
        mockMvc.perform(get("/api/products/" + productId)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().is2xxSuccessful())
                .andExpect(jsonPath("$.id").value(productId))
                .andExpect(jsonPath("$.name").value("Товар для получения по ID"));
    }

    @Test
    void deleteProduct_ExistingProduct_ReturnsSuccess() throws Exception {
        // Arrange — создаём товар
        Map<String, Object> request = Map.of(
                "sku", "DELETE-ME-" + System.currentTimeMillis(),
                "name", "Товар на удаление",
                "price", new BigDecimal("100.00"),
                "currentStock", 5L
        );
        MvcResult created = mockMvc.perform(post("/api/products")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        Long productId = objectMapper.readTree(created.getResponse().getContentAsString())
                .get("id").asLong();

        // Act — удаляем
        mockMvc.perform(delete("/api/products/" + productId)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().is2xxSuccessful());

        // Assert — товар больше не существует (404)
        mockMvc.perform(get("/api/products/" + productId)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isNotFound());
    }

    @Test
    void getProducts_WithSearch_ReturnsFilteredResults() throws Exception {
        // Arrange — создаём товар с уникальным именем
        String uniqueName = "УникальноеИмя" + System.currentTimeMillis();
        Map<String, Object> request = Map.of(
                "sku", "SEARCH-" + System.currentTimeMillis(),
                "name", uniqueName,
                "price", new BigDecimal("100.00"),
                "currentStock", 10L
        );
        mockMvc.perform(post("/api/products")
                        .header("Authorization", "Bearer " + adminToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful());

        // Act — ищем по имени
        mockMvc.perform(get("/api/products?q=" + uniqueName)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().is2xxSuccessful())
                .andExpect(jsonPath("$.content", hasSize(greaterThanOrEqualTo(1))))
                .andExpect(jsonPath("$.content[0].name").value(uniqueName));
    }
}
