package org.ngcvfb.inventorymanagementapi.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class AuthControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    @Order(1)
    void register_NewUser_ReturnsTokenSuccessfully() throws Exception {
        // Arrange
        Map<String, String> request = Map.of(
                "username", "integrationuser",
                "password", "password123",
                "fullName", "Integration User"
        );

        // Act & Assert
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful())
                .andExpect(jsonPath("$.token").exists())
                .andExpect(jsonPath("$.token").isNotEmpty());
    }

    @Test
    @Order(2)
    void login_CorrectCredentials_ReturnsToken() throws Exception {
        // Arrange — сначала регистрируем пользователя
        Map<String, String> registerReq = Map.of(
                "username", "logintest",
                "password", "secret123",
                "fullName", "Login Test"
        );
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerReq)))
                .andExpect(status().is2xxSuccessful());

        // Act — логинимся
        Map<String, String> loginReq = Map.of(
                "username", "logintest",
                "password", "secret123"
        );

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().is2xxSuccessful())
                .andExpect(jsonPath("$.token").exists())
                .andExpect(jsonPath("$.token").isNotEmpty());
    }

    @Test
    @Order(3)
    void login_WrongPassword_Returns401() throws Exception {
        // Arrange — регистрируем пользователя
        Map<String, String> registerReq = Map.of(
                "username", "wrongpassuser",
                "password", "correctpassword",
                "fullName", "Wrong Pass User"
        );
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(registerReq)))
                .andExpect(status().is2xxSuccessful());

        // Act — логинимся с неверным паролем
        Map<String, String> loginReq = Map.of(
                "username", "wrongpassuser",
                "password", "НЕВЕРНЫЙ_ПАРОЛЬ"
        );

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Неверный логин или пароль"));
    }

    @Test
    @Order(4)
    void login_NonexistentUser_Returns401() throws Exception {
        // Arrange
        Map<String, String> loginReq = Map.of(
                "username", "noexist",
                "password", "somepassword"
        );

        // Act & Assert
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Неверный логин или пароль"));
    }

    @Test
    @Order(5)
    void register_DuplicateUsername_Returns409() throws Exception {
        // Arrange — первая регистрация
        Map<String, String> request = Map.of(
                "username", "duplicateuser",
                "password", "password123",
                "fullName", "Duplicate"
        );
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().is2xxSuccessful());

        // Act — повторная регистрация с тем же username
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.message").value("Пользователь с таким логином уже существует"));
    }
}
