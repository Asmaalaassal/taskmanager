package com.ticketmanager.service;

import com.ticketmanager.dto.*;
import com.ticketmanager.entity.ProblemType;
import com.ticketmanager.entity.Priority;
import com.ticketmanager.entity.Role;
import com.ticketmanager.entity.Ticket;
import com.ticketmanager.entity.TicketStatus;
import com.ticketmanager.entity.User;
import com.ticketmanager.exception.ResourceNotFoundException;
import com.ticketmanager.repository.ProblemTypeRepository;
import com.ticketmanager.repository.ReplyRepository;
import com.ticketmanager.repository.TicketRepository;
import com.ticketmanager.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TicketService {
    private final TicketRepository ticketRepository;
    private final UserRepository userRepository;
    private final UserService userService;
    private final ProblemTypeRepository problemTypeRepository;
    private final ReplyRepository replyRepository;

    @Transactional
    public TicketResponse createTicket(CreateTicketRequest request, String creatorEmail) {
        User creator = userService.findByEmail(creatorEmail);

        ProblemType problemType = problemTypeRepository.findById(request.getProblemTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Problem type not found with id: " + request.getProblemTypeId()));

        Ticket ticket = new Ticket();
        ticket.setTitle(request.getTitle());
        ticket.setDescription(request.getDescription());
        ticket.setStatus(TicketStatus.OPEN);
        ticket.setPriority(request.getPriority());
        ticket.setCreatedBy(creator);
        ticket.setProblemType(problemType);
        ticket.setIsPublic(request.getIsPublic() != null ? request.getIsPublic() : true);

        Ticket savedTicket = ticketRepository.save(ticket);

        // Auto-dispatch to agent with matching specialization and least tickets
        dispatchTicketToAgent(savedTicket);

        return mapToTicketResponse(savedTicket);
    }

    private void dispatchTicketToAgent(Ticket ticket) {
        if (ticket.getProblemType() == null) {
            return;
        }

        List<User> agents = userRepository.findAgentsByProblemType(ticket.getProblemType().getId());

        if (agents.isEmpty()) {
            return; // No agents available for this problem type
        }

        // Find agent with least active tickets
        User selectedAgent = agents.stream()
                .min(Comparator.comparing(agent -> 
                    ticketRepository.countActiveTicketsByAgent(agent.getId())))
                .orElse(agents.get(0));

        ticket.setAssignedTo(selectedAgent);
        ticketRepository.save(ticket);
    }

    @Transactional(readOnly = true)
    public List<TicketResponse> getAllTickets(String userEmail, TicketStatus status, Priority priority, Long problemTypeId, Boolean isPublic) {
        User user = userService.findByEmail(userEmail);
        List<Ticket> tickets;

        if (user.getRole() == Role.ADMIN) {
            if (status != null || priority != null || problemTypeId != null || isPublic != null) {
                tickets = ticketRepository.findTicketsWithFilters(status, priority, problemTypeId, isPublic);
            } else {
                tickets = ticketRepository.findAll();
            }
        } else if (user.getRole() == Role.AGENT) {
            tickets = ticketRepository.findByAssignedToId(user.getId());
            // Apply filters if provided
            if (status != null) {
                tickets = tickets.stream().filter(t -> t.getStatus() == status).collect(Collectors.toList());
            }
            if (priority != null) {
                tickets = tickets.stream().filter(t -> t.getPriority() == priority).collect(Collectors.toList());
            }
        } else { // USER role
            tickets = ticketRepository.findByCreatedById(user.getId());
            // Apply filters if provided
            if (status != null) {
                tickets = tickets.stream().filter(t -> t.getStatus() == status).collect(Collectors.toList());
            }
            if (priority != null) {
                tickets = tickets.stream().filter(t -> t.getPriority() == priority).collect(Collectors.toList());
            }
            if (problemTypeId != null) {
                tickets = tickets.stream().filter(t -> t.getProblemType() != null && t.getProblemType().getId().equals(problemTypeId)).collect(Collectors.toList());
            }
        }

        return tickets.stream()
                .map(this::mapToTicketResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public TicketResponse getTicketById(Long id, String userEmail) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found with id: " + id));

        User user = userService.findByEmail(userEmail);

        // Access control
        if (user.getRole() == Role.ADMIN) {
            // Admin can see all tickets
        } else if (user.getRole() == Role.AGENT) {
            // Agent can see assigned tickets or public tickets
            if (ticket.getAssignedTo() == null || !ticket.getAssignedTo().getId().equals(user.getId())) {
                if (!ticket.getIsPublic()) {
                    throw new RuntimeException("Access denied");
                }
            }
        } else { // USER role
            // User can see their own tickets or public tickets
            if (!ticket.getCreatedBy().getId().equals(user.getId()) && !ticket.getIsPublic()) {
                throw new RuntimeException("Access denied");
            }
        }

        return mapToTicketResponse(ticket);
    }

    @Transactional
    public TicketResponse updateTicket(Long id, UpdateTicketRequest request, String userEmail) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found with id: " + id));

        User user = userService.findByEmail(userEmail);
        if (!user.getRole().name().equals("ADMIN") && 
            (ticket.getAssignedTo() == null || !ticket.getAssignedTo().getId().equals(user.getId()))) {
            throw new RuntimeException("Access denied");
        }

        if (request.getStatus() != null) {
            ticket.setStatus(request.getStatus());
        }
        if (request.getPriority() != null) {
            ticket.setPriority(request.getPriority());
        }

        Ticket updatedTicket = ticketRepository.save(ticket);
        return mapToTicketResponse(updatedTicket);
    }

    @Transactional
    public TicketResponse assignTicket(Long id, AssignTicketRequest request) {
        Ticket ticket = ticketRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found with id: " + id));

        User agent = userRepository.findById(request.getAgentId())
                .orElseThrow(() -> new ResourceNotFoundException("Agent not found with id: " + request.getAgentId()));

        if (!agent.getRole().name().equals("AGENT")) {
            throw new RuntimeException("User is not an agent");
        }

        ticket.setAssignedTo(agent);
        Ticket updatedTicket = ticketRepository.save(ticket);
        return mapToTicketResponse(updatedTicket);
    }

    @Transactional
    public void deleteTicket(Long id) {
        if (!ticketRepository.existsById(id)) {
            throw new ResourceNotFoundException("Ticket not found with id: " + id);
        }
        ticketRepository.deleteById(id);
    }

    private TicketResponse mapToTicketResponse(Ticket ticket) {
        UserResponse createdBy = new UserResponse(
                ticket.getCreatedBy().getId(),
                ticket.getCreatedBy().getName(),
                ticket.getCreatedBy().getEmail(),
                ticket.getCreatedBy().getRole()
        );

        UserResponse assignedTo = null;
        if (ticket.getAssignedTo() != null) {
            assignedTo = new UserResponse(
                    ticket.getAssignedTo().getId(),
                    ticket.getAssignedTo().getName(),
                    ticket.getAssignedTo().getEmail(),
                    ticket.getAssignedTo().getRole()
            );
        }

        ProblemTypeResponse problemType = null;
        if (ticket.getProblemType() != null) {
            problemType = new ProblemTypeResponse(
                    ticket.getProblemType().getId(),
                    ticket.getProblemType().getName(),
                    ticket.getProblemType().getDescription()
            );
        }

        List<ReplyResponse> replies = replyRepository.findByTicketIdOrderByCreatedAtAsc(ticket.getId())
                .stream()
                .map(reply -> new ReplyResponse(
                        reply.getId(),
                        reply.getContent(),
                        reply.getCreatedAt(),
                        new UserResponse(
                                reply.getUser().getId(),
                                reply.getUser().getName(),
                                reply.getUser().getEmail(),
                                reply.getUser().getRole()
                        )
                ))
                .collect(Collectors.toList());

        return new TicketResponse(
                ticket.getId(),
                ticket.getTitle(),
                ticket.getDescription(),
                ticket.getStatus(),
                ticket.getPriority(),
                ticket.getCreatedAt(),
                createdBy,
                assignedTo,
                problemType,
                ticket.getIsPublic(),
                replies
        );
    }
}

