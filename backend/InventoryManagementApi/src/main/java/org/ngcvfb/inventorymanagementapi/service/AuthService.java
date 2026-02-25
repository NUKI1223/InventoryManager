package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.config.JwtUtil;
import org.ngcvfb.inventorymanagementapi.dto.LoginRequest;
import org.ngcvfb.inventorymanagementapi.dto.LoginResponse;
import org.ngcvfb.inventorymanagementapi.dto.RegisterRequest;
import org.ngcvfb.inventorymanagementapi.model.User;
import org.ngcvfb.inventorymanagementapi.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {
    private final UserRepository userRepo;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    public AuthService(UserRepository userRepo, JwtUtil jwtUtil, PasswordEncoder passwordEncoder) {
        this.userRepo = userRepo;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = passwordEncoder;
    }

    // Login — теперь с BCrypt-проверкой
    public LoginResponse login(LoginRequest req) {
        User user = userRepo.findByUsername(req.getUsername())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Неверный логин или пароль"));

        if (!passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Неверный логин или пароль");
        }
        String token = jwtUtil.generateToken(user);
        return new LoginResponse(token);
    }

    // Register — создаёт нового пользователя
    public LoginResponse register(RegisterRequest req) {
        String username = req.getUsername();
        String password = req.getPassword();

        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Необходимо указать логин и пароль");
        }

        userRepo.findByUsername(username).ifPresent(u -> {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Пользователь с таким логином уже существует");
        });

        User u = new User();
        u.setUsername(username);
        u.setPasswordHash(passwordEncoder.encode(password)); // хешируем
        u.setFullName(req.getFullName());
        u.setRole("USER"); // по умолчанию роль USER. Можно менять.
        userRepo.save(u);

        String token = jwtUtil.generateToken(u);
        return new LoginResponse(token); // сразу возвращаем токен (удобно для клиента)
    }
}

