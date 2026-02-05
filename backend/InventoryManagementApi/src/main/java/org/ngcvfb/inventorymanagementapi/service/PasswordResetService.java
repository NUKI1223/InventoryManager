package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.model.PasswordResetRequest;
import org.ngcvfb.inventorymanagementapi.model.User;
import org.ngcvfb.inventorymanagementapi.repository.PasswordResetRepository;
import org.ngcvfb.inventorymanagementapi.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class PasswordResetService {
    private final PasswordResetRepository resetRepository;
    private final UserRepository userRepository;

    public PasswordResetService(PasswordResetRepository resetRepository, UserRepository userRepository) {
        this.resetRepository = resetRepository;
        this.userRepository = userRepository;
    }

    public PasswordResetRequest createResetRequest(String username) {
        // Verify user exists
        userRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        PasswordResetRequest request = new PasswordResetRequest();
        request.setUsername(username);
        return resetRepository.save(request);
    }

    public List<PasswordResetRequest> getPendingRequests() {
        return resetRepository.findByStatusOrderByRequestedAtDesc("PENDING");
    }

    public void completeRequest(Long requestId) {
        PasswordResetRequest request = resetRepository.findById(requestId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Request not found"));
        request.setStatus("COMPLETED");
        resetRepository.save(request);
    }

    public void rejectRequest(Long requestId) {
        PasswordResetRequest request = resetRepository.findById(requestId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Request not found"));
        request.setStatus("REJECTED");
        resetRepository.save(request);
    }
}


