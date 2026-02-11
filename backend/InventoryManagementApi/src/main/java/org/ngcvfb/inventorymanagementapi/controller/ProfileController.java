package org.ngcvfb.inventorymanagementapi.controller;

import org.ngcvfb.inventorymanagementapi.dto.ChangePasswordRequest;
import org.ngcvfb.inventorymanagementapi.dto.UpdateProfileRequest;
import org.ngcvfb.inventorymanagementapi.dto.UserResponse;
import org.ngcvfb.inventorymanagementapi.model.User;
import org.ngcvfb.inventorymanagementapi.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
@RequestMapping("/api/profile")
public class ProfileController {
    private final UserRepository userRepo;
    private final PasswordEncoder passwordEncoder;

    public ProfileController(UserRepository userRepo, PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping
    public UserResponse getProfile(Authentication authentication) {
        Long userId = Long.parseLong(authentication.getName());
        User user = userRepo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        return new UserResponse(user.getId(), user.getUsername(), user.getFullName(), user.getRole());
    }

    @PutMapping
    public UserResponse updateProfile(@RequestBody UpdateProfileRequest request, Authentication authentication) {
        Long userId = Long.parseLong(authentication.getName());
        User user = userRepo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        if (request.getUsername() != null && !request.getUsername().isBlank()) {
            // Check if username is taken by another user
            userRepo.findByUsername(request.getUsername()).ifPresent(existing -> {
                if (!existing.getId().equals(userId)) {
                    throw new ResponseStatusException(HttpStatus.CONFLICT, "Username already taken");
                }
            });
            user.setUsername(request.getUsername());
        }

        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }

        userRepo.save(user);
        return new UserResponse(user.getId(), user.getUsername(), user.getFullName(), user.getRole());
    }

    @PutMapping("/password")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request, Authentication authentication) {
        Long userId = Long.parseLong(authentication.getName());
        User user = userRepo.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Old password is incorrect");
        }

        if (request.getNewPassword() == null || request.getNewPassword().length() < 6) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "New password must be at least 6 characters");
        }

        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepo.save(user);

        return ResponseEntity.ok(Map.of("message", "Password changed successfully"));
    }
}
