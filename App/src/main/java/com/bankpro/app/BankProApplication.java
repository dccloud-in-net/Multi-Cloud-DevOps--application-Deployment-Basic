package com.bankpro.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
@RestController
public class BankProApplication {

    public static void main(String[] args) {
        SpringApplication.run(BankProApplication.class, args);
    }

    @GetMapping("/")
    public Map<String, Object> getStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("status", "UP");
        status.put("application", "BankPro Microservice Platform");
        status.put("version", "1.0.0");
        status.put("message", "Welcome to BankPro Multi-Cloud Banking Application!");
        return status;
    }
}
