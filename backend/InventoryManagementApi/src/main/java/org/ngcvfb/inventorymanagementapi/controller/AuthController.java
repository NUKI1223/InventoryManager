package org.ngcvfb.inventorymanagementapi.controller;

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
public class AuthController {
    private static final Logger log = LoggerFactory.getLogger(AuthController.class);

    private final AuthService authService;
    private final PasswordResetService passwordResetService;

    public AuthController(AuthService authService, PasswordResetService passwordResetService) {
        this.authService = authService;
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest req) {
        log.info("Login attempt for user: {}", req.getUsername());
        LoginResponse resp = authService.login(req);
        log.debug("Login successful, token generated for user: {}", req.getUsername());
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/register")
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

