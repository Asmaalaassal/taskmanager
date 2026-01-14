package com.ticketmanager.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProblemTypeResponse {
    private Long id;
    private String name;
    private String description;
}

