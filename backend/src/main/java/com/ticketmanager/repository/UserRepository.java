package com.ticketmanager.repository;

import com.ticketmanager.entity.Role;
import com.ticketmanager.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByRole(Role role);
    
    @Query("SELECT DISTINCT u FROM User u JOIN u.specializations s WHERE s.id = :problemTypeId AND u.role = 'AGENT'")
    List<User> findAgentsByProblemType(@Param("problemTypeId") Long problemTypeId);
}

