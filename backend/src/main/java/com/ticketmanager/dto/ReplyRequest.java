package com.ticketmanager.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ReplyRequest {
    @NotBlank(message = "Content is required")
    private String content;
}

