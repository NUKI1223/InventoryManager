package org.ngcvfb.inventorymanagementapi.controller;

import org.ngcvfb.inventorymanagementapi.dto.ResetPasswordRequest;
import org.ngcvfb.inventorymanagementapi.dto.UpdateUserRequest;
import org.ngcvfb.inventorymanagementapi.dto.UserResponse;
import org.ngcvfb.inventorymanagementapi.model.PasswordResetRequest;
import org.ngcvfb.inventorymanagementapi.service.PasswordResetService;
import org.ngcvfb.inventorymanagementapi.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final UserService userService;
    private final PasswordResetService passwordResetService;

    public AdminController(UserService userService, PasswordResetService passwordResetService) {
        this.userService = userService;
        this.passwordResetService = passwordResetService;
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<UserResponse> updateUser(@PathVariable Long id, @RequestBody UpdateUserRequest request) {
        return ResponseEntity.ok(userService.updateUser(id, request));
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<Map<String, String>> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.ok(Map.of("message", "User deleted successfully"));
    }

    @GetMapping("/password-resets")
    public ResponseEntity<List<PasswordResetRequest>> getPendingResets() {
        return ResponseEntity.ok(passwordResetService.getPendingRequests());
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, String>> resetPassword(@RequestBody ResetPasswordRequest request) {
        userService.resetPassword(request.getUserId(), request.getNewPassword());
        return ResponseEntity.ok(Map.of("message", "Password reset successfully"));
    }

    @PostMapping("/password-resets/{id}/complete")
    public ResponseEntity<Map<String, String>> completeReset(@PathVariable Long id) {
        passwordResetService.completeRequest(id);
        return ResponseEntity.ok(Map.of("message", "Request completed"));
    }

    @PostMapping("/password-resets/{id}/reject")
    public ResponseEntity<Map<String, String>> rejectReset(@PathVariable Long id) {
        passwordResetService.rejectRequest(id);
        return ResponseEntity.ok(Map.of("message", "Request rejected"));
    }
}

