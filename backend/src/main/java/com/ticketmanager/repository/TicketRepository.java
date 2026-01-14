package com.ticketmanager.repository;

import com.ticketmanager.entity.Ticket;
import com.ticketmanager.entity.TicketStatus;
import com.ticketmanager.entity.Priority;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TicketRepository extends JpaRepository<Ticket, Long> {
    List<Ticket> findByAssignedToId(Long agentId);
    List<Ticket> findByCreatedById(Long userId);
    List<Ticket> findByProblemTypeId(Long problemTypeId);
    List<Ticket> findByIsPublic(Boolean isPublic);
    
    @Query("SELECT t FROM Ticket t WHERE t.problemType.id = :problemTypeId AND t.assignedTo IS NOT NULL")
    List<Ticket> findAssignedTicketsByProblemType(@Param("problemTypeId") Long problemTypeId);
    
    @Query("SELECT COUNT(t) FROM Ticket t WHERE t.assignedTo.id = :agentId AND t.status != 'CLOSED'")
    Long countActiveTicketsByAgent(@Param("agentId") Long agentId);
    
    @Query("SELECT t FROM Ticket t WHERE " +
           "(:status IS NULL OR t.status = :status) AND " +
           "(:priority IS NULL OR t.priority = :priority) AND " +
           "(:problemTypeId IS NULL OR t.problemType.id = :problemTypeId) AND " +
           "(:isPublic IS NULL OR t.isPublic = :isPublic)")
    List<Ticket> findTicketsWithFilters(
        @Param("status") TicketStatus status,
        @Param("priority") Priority priority,
        @Param("problemTypeId") Long problemTypeId,
        @Param("isPublic") Boolean isPublic
    );
}

