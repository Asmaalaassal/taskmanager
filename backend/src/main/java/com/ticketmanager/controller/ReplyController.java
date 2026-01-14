package com.ticketmanager.controller;

import com.ticketmanager.dto.ReplyRequest;
import com.ticketmanager.dto.ReplyResponse;
import com.ticketmanager.service.ReplyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tickets/{ticketId}/replies")
@RequiredArgsConstructor
public class ReplyController {
    private final ReplyService replyService;

    @PostMapping
    public ResponseEntity<ReplyResponse> createReply(
            @PathVariable Long ticketId,
            @Valid @RequestBody ReplyRequest request,
            Authentication authentication) {
        String email = authentication.getName();
        ReplyResponse response = replyService.createReply(ticketId, request, email);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<ReplyResponse>> getRepliesByTicketId(@PathVariable Long ticketId) {
        List<ReplyResponse> replies = replyService.getRepliesByTicketId(ticketId);
        return ResponseEntity.ok(replies);
    }
}

