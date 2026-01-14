package com.ticketmanager.controller;

import com.ticketmanager.dto.CreateAgentRequest;
import com.ticketmanager.dto.UserResponse;
import com.ticketmanager.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/agents")
@RequiredArgsConstructor
public class AgentController {
    private final UserService userService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> createAgent(@Valid @RequestBody CreateAgentRequest request) {
        UserResponse response = userService.createAgent(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<UserResponse>> getAllAgents() {
        List<UserResponse> agents = userService.getAllAgents();
        return ResponseEntity.ok(agents);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<UserResponse> getAgentById(@PathVariable Long id) {
        UserResponse agent = userService.getAgentById(id);
        return ResponseEntity.ok(agent);
    }
}

