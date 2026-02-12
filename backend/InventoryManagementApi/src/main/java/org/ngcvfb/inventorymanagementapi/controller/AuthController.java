package org.ngcvfb.inventorymanagementapi.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import org.ngcvfb.inventorymanagementapi.dto.ForgotPasswordRequest;
import org.ngcvfb.inventorymanagementapi.dto.LoginRequest;
import org.ngcvfb.inventorymanagementapi.dto.LoginResponse;
import org.ngcvfb.inventorymanagementapi.dto.RegisterRequest;
import org.ngcvfb.inventorymanagementapi.service.AuthService;
import org.ngcvfb.inventorymanagementapi.service.PasswordResetService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Authentication", description = "API для аутентификации и регистрации пользователей")
public class AuthController {
    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final AuthService authService;
    private final PasswordResetService passwordResetService;

    public AuthController(AuthService authService, PasswordResetService passwordResetService) {
        this.authService = authService;
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/login")
    @Operation(summary = "Вход в систему", description = "Аутентификация пользователя по логину и паролю")
    @ApiResponse(responseCode = "200", description = "Успешный вход", content = @Content(schema = @Schema(implementation = LoginResponse.class)))
    @ApiResponse(responseCode = "401", description = "Неверные учетные данные")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest req) {
        log.info("Login attempt for user: {}", req.getUsername());
        LoginResponse resp = authService.login(req);
        log.debug("Login successful, token generated for user: {}", req.getUsername());
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/register")
    @Operation(summary = "Регистрация нового пользователя", description = "Создание нового аккаунта пользователя")
    @ApiResponse(responseCode = "201", description = "Пользователь успешно зарегистрирован")
    @ApiResponse(responseCode = "409", description = "Пользователь с таким именем уже существует")
    public ResponseEntity<LoginResponse> register(@RequestBody RegisterRequest req) {
        log.info("Registration attempt for user: {}", req.getUsername());
        LoginResponse resp = authService.register(req);
        log.info("User registered successfully: {}", req.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, String>> forgotPassword(@RequestBody ForgotPasswordRequest request) {
        log.info("Password reset request for user: {}", request.getUsername());
        passwordResetService.createResetRequest(request.getUsername());
        return ResponseEntity.ok(Map.of("message", "Password reset request submitted"));
    }
}

