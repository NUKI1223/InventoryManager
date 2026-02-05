package org.ngcvfb.inventorymanagementapi.controller;

import org.ngcvfb.inventorymanagementapi.dto.ForgotPasswordRequest;
import org.ngcvfb.inventorymanagementapi.dto.LoginRequest;
import org.ngcvfb.inventorymanagementapi.dto.LoginResponse;
import org.ngcvfb.inventorymanagementapi.dto.RegisterRequest;
import org.ngcvfb.inventorymanagementapi.service.AuthService;
import org.ngcvfb.inventorymanagementapi.service.PasswordResetService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;
    private final PasswordResetService passwordResetService;

    public AuthController(AuthService authService, PasswordResetService passwordResetService) {
        this.authService = authService;
        this.passwordResetService = passwordResetService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest req) {
        LoginResponse resp = authService.login(req);
        System.out.println("AUTH-CONTROLLER: returning token present=" + (resp != null && resp.getToken() != null));
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/register")
    public ResponseEntity<LoginResponse> register(@RequestBody RegisterRequest req) {
        LoginResponse resp = authService.register(req);
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, String>> forgotPassword(@RequestBody ForgotPasswordRequest request) {
        passwordResetService.createResetRequest(request.getUsername());
        return ResponseEntity.ok(Map.of("message", "Password reset request submitted"));
    }
}

