package com.ticketmanager.dto;

import com.ticketmanager.entity.Priority;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateTicketRequest {
    @NotBlank(message = "Title is required")
    private String title;

    @NotBlank(message = "Description is required")
    private String description;

    @NotNull(message = "Priority is required")
    private Priority priority;

    @NotNull(message = "Problem type is required")
    private Long problemTypeId;

    private Boolean isPublic = true;
}

