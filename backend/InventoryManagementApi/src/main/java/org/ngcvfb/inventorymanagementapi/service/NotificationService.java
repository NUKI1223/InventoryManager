package org.ngcvfb.inventorymanagementapi.service;

import org.ngcvfb.inventorymanagementapi.model.Notification;
import org.ngcvfb.inventorymanagementapi.model.Product;
import org.ngcvfb.inventorymanagementapi.model.User;
import org.ngcvfb.inventorymanagementapi.repository.NotificationRepository;
import org.ngcvfb.inventorymanagementapi.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class NotificationService {
    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    private final NotificationRepository notificationRepository;
    private final UserRepository userRepository;

    public NotificationService(NotificationRepository notificationRepository, UserRepository userRepository) {
        this.notificationRepository = notificationRepository;
        this.userRepository = userRepository;
    }

    public Page<Notification> getUserNotifications(Long userId, Pageable pageable) {
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    }

    public Long getUnreadCount(Long userId) {
        return notificationRepository.countByUserIdAndIsReadFalse(userId);
    }

    public Notification markAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Notification not found"));
        notification.setIsRead(true);
        return notificationRepository.save(notification);
    }

    @Transactional
    public void deleteNotification(Long notificationId) {
        notificationRepository.deleteById(notificationId);
    }

    @Transactional
    public void deleteAllUserNotifications(Long userId) {
        notificationRepository.deleteByUserId(userId);
    }

    public Notification createNotification(Long userId, String title, String message, String type) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Notification notification = new Notification(user, title, message, type);
        Notification saved = notificationRepository.save(notification);
        log.info("Created notification for user {}: {}", userId, title);
        return saved;
    }

    public Notification createLowStockNotification(User user, Product product) {
        Notification notification = new Notification(
                user,
                "Низкий запас товара",
                String.format("Товар '%s' (SKU: %s) имеет низкий запас: %d шт.",
                        product.getName(), product.getSku(), product.getCurrentStock()),
                "LOW_STOCK"
        );
        notification.setProduct(product);
        Notification saved = notificationRepository.save(notification);
        log.info("Created low stock notification for product {} (stock: {})", product.getName(), product.getCurrentStock());
        return saved;
    }

    public void notifyAllAdminsLowStock(Product product) {
        List<User> admins = userRepository.findByRole("ADMIN");
        for (User admin : admins) {
            createLowStockNotification(admin, product);
        }
    }
}
