package com.ticketmanager.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReplyResponse {
    private Long id;
    private String content;
    private LocalDateTime createdAt;
    private UserResponse user;
}

