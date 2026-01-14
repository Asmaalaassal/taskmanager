package com.ticketmanager.controller;

import com.ticketmanager.dto.*;
import com.ticketmanager.entity.Priority;
import com.ticketmanager.entity.TicketStatus;
import com.ticketmanager.service.TicketService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tickets")
@RequiredArgsConstructor
public class TicketController {
    private final TicketService ticketService;

    @PostMapping
    public ResponseEntity<TicketResponse> createTicket(
            @Valid @RequestBody CreateTicketRequest request,
            Authentication authentication) {
        String email = authentication.getName();
        TicketResponse response = ticketService.createTicket(request, email);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<TicketResponse>> getAllTickets(
            @RequestParam(required = false) TicketStatus status,
            @RequestParam(required = false) Priority priority,
            @RequestParam(required = false) Long problemTypeId,
            @RequestParam(required = false) Boolean isPublic,
            Authentication authentication) {
        String email = authentication.getName();
        List<TicketResponse> tickets = ticketService.getAllTickets(email, status, priority, problemTypeId, isPublic);
        return ResponseEntity.ok(tickets);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TicketResponse> getTicketById(
            @PathVariable Long id,
            Authentication authentication) {
        String email = authentication.getName();
        TicketResponse ticket = ticketService.getTicketById(id, email);
        return ResponseEntity.ok(ticket);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TicketResponse> updateTicket(
            @PathVariable Long id,
            @Valid @RequestBody UpdateTicketRequest request,
            Authentication authentication) {
        String email = authentication.getName();
        TicketResponse response = ticketService.updateTicket(id, request, email);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}/assign")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<TicketResponse> assignTicket(
            @PathVariable Long id,
            @Valid @RequestBody AssignTicketRequest request) {
        TicketResponse response = ticketService.assignTicket(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteTicket(@PathVariable Long id) {
        ticketService.deleteTicket(id);
        return ResponseEntity.noContent().build();
    }
}

