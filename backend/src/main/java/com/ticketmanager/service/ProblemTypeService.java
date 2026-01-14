package com.ticketmanager.service;

import com.ticketmanager.dto.ProblemTypeResponse;
import com.ticketmanager.entity.ProblemType;
import com.ticketmanager.repository.ProblemTypeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProblemTypeService {
    private final ProblemTypeRepository problemTypeRepository;

    @Transactional(readOnly = true)
    public List<ProblemTypeResponse> getAllProblemTypes() {
        return problemTypeRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ProblemTypeResponse getProblemTypeById(Long id) {
        ProblemType problemType = problemTypeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Problem type not found with id: " + id));
        return mapToResponse(problemType);
    }

    private ProblemTypeResponse mapToResponse(ProblemType problemType) {
        return new ProblemTypeResponse(problemType.getId(), problemType.getName(), problemType.getDescription());
    }
}

