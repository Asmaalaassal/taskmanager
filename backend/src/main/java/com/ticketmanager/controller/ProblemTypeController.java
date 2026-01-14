package com.ticketmanager.controller;

import com.ticketmanager.dto.ProblemTypeResponse;
import com.ticketmanager.service.ProblemTypeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/problem-types")
@RequiredArgsConstructor
public class ProblemTypeController {
    private final ProblemTypeService problemTypeService;

    @GetMapping
    public ResponseEntity<List<ProblemTypeResponse>> getAllProblemTypes() {
        List<ProblemTypeResponse> problemTypes = problemTypeService.getAllProblemTypes();
        return ResponseEntity.ok(problemTypes);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ProblemTypeResponse> getProblemTypeById(@PathVariable Long id) {
        ProblemTypeResponse problemType = problemTypeService.getProblemTypeById(id);
        return ResponseEntity.ok(problemType);
    }
}

