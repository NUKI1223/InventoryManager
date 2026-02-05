package org.ngcvfb.inventorymanagementapi.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/debug")
public class DebugController {

    @GetMapping("/whoami")
    public Map<String, Object> whoami(HttpServletRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        Map<String, Object> m = new HashMap<>();
        if (auth == null) {
            m.put("authenticated", false);
        } else {
            m.put("authenticated", true);
            m.put("principal", auth.getPrincipal());
            m.put("name", auth.getName());
            m.put("authorities", auth.getAuthorities());
            m.put("details", auth.getDetails());
        }

        Map<String, String> headers = new HashMap<>();
        Enumeration<String> names = request.getHeaderNames();
        if (names != null) {
            while (names.hasMoreElements()) {
                String n = names.nextElement();
                headers.put(n, request.getHeader(n));
            }
        }
        m.put("requestHeaders", headers);
        return m;
    }
}
