package com.ticketmanager.dto;

import com.ticketmanager.entity.Priority;
import com.ticketmanager.entity.TicketStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TicketResponse {
    private Long id;
    private String title;
    private String description;
    private TicketStatus status;
    private Priority priority;
    private LocalDateTime createdAt;
    private UserResponse createdBy;
    private UserResponse assignedTo;
    private ProblemTypeResponse problemType;
    private Boolean isPublic;
    private List<ReplyResponse> replies;
}

