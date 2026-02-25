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

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@ActiveProfiles("test")
class CategoryControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private String authToken;

    @BeforeEach
    void setUp() throws Exception {
        // Создаём ADMIN пользователя через репозиторий (POST /categories требует ADMIN)
        String adminUsername = "catadmin_" + System.currentTimeMillis();
        User admin = new User();
        admin.setUsername(adminUsername);
        admin.setPasswordHash(passwordEncoder.encode("adminpass"));
        admin.setRole("ADMIN");
        admin.setFullName("Category Admin");
        userRepository.save(admin);

        Map<String, String> loginReq = Map.of("username", adminUsername, "password", "adminpass");
        MvcResult result = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        authToken = objectMapper.readTree(result.getResponse().getContentAsString())
                .get("token").asText();
    }

    @Test
    void getCategories_AuthenticatedUser_ReturnsOk() throws Exception {
        mockMvc.perform(get("/api/categories")
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().is2xxSuccessful())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }

    @Test
    void createCategory_ValidData_ReturnsCreatedCategory() throws Exception {
        // Arrange
        Map<String, String> request = Map.of(
                "name", "Тест Категория " + System.currentTimeMillis(),
                "description", "Описание тестовой категории"
        );

        // Act & Assert
        mockMvc.perform(post("/api/categories")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.name").isNotEmpty());
    }

    @Test
    void createCategory_DuplicateName_Returns409() throws Exception {
        // Arrange — создаём категорию
        String categoryName = "Дубль " + System.currentTimeMillis();
        Map<String, String> request = Map.of("name", categoryName, "description", "desc");

        mockMvc.perform(post("/api/categories")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful());

        // Act — создаём с тем же именем
        mockMvc.perform(post("/api/categories")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("Категория с таким названием уже существует"));
    }

    @Test
    void getCategories_WithoutToken_Returns401or403() throws Exception {
        mockMvc.perform(get("/api/categories"))
                .andExpect(result ->
                        org.junit.jupiter.api.Assertions.assertTrue(
                                result.getResponse().getStatus() == 401 ||
                                        result.getResponse().getStatus() == 403
                        ));
    }

    @Test
    void deleteCategory_ExistingCategory_ReturnsNoContent() throws Exception {
        // Arrange — создаём категорию
        Map<String, String> request = Map.of(
                "name", "На удаление " + System.currentTimeMillis(),
                "description", "desc"
        );
        MvcResult created = mockMvc.perform(post("/api/categories")
                        .header("Authorization", "Bearer " + authToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        Long categoryId = objectMapper.readTree(created.getResponse().getContentAsString())
                .get("id").asLong();

        // Act — удаляем
        mockMvc.perform(delete("/api/categories/" + categoryId)
                        .header("Authorization", "Bearer " + authToken))
                .andExpect(status().is2xxSuccessful());
    }
}
