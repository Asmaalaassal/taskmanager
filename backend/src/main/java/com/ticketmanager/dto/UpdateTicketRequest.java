package com.ticketmanager.dto;

import com.ticketmanager.entity.Priority;
import com.ticketmanager.entity.TicketStatus;
import lombok.Data;

@Data
public class UpdateTicketRequest {
    private TicketStatus status;
    private Priority priority;
}

