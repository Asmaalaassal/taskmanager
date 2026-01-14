package com.ticketmanager.repository;

import com.ticketmanager.entity.ProblemType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ProblemTypeRepository extends JpaRepository<ProblemType, Long> {
    Optional<ProblemType> findByName(String name);
}

