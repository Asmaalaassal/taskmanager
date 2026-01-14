package com.ticketmanager.service;

import com.ticketmanager.dto.ReplyRequest;
import com.ticketmanager.dto.ReplyResponse;
import com.ticketmanager.entity.Reply;
import com.ticketmanager.entity.Ticket;
import com.ticketmanager.entity.User;
import com.ticketmanager.exception.ResourceNotFoundException;
import com.ticketmanager.repository.ReplyRepository;
import com.ticketmanager.repository.TicketRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReplyService {
    private final ReplyRepository replyRepository;
    private final TicketRepository ticketRepository;
    private final UserService userService;

    @Transactional
    public ReplyResponse createReply(Long ticketId, ReplyRequest request, String userEmail) {
        Ticket ticket = ticketRepository.findById(ticketId)
                .orElseThrow(() -> new ResourceNotFoundException("Ticket not found with id: " + ticketId));

        User user = userService.findByEmail(userEmail);

        Reply reply = new Reply();
        reply.setTicket(ticket);
        reply.setUser(user);
        reply.setContent(request.getContent());

        Reply savedReply = replyRepository.save(reply);
        return mapToResponse(savedReply);
    }

    @Transactional(readOnly = true)
    public List<ReplyResponse> getRepliesByTicketId(Long ticketId) {
        return replyRepository.findByTicketIdOrderByCreatedAtAsc(ticketId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private ReplyResponse mapToResponse(Reply reply) {
        return new ReplyResponse(
                reply.getId(),
                reply.getContent(),
                reply.getCreatedAt(),
                new com.ticketmanager.dto.UserResponse(
                        reply.getUser().getId(),
                        reply.getUser().getName(),
                        reply.getUser().getEmail(),
                        reply.getUser().getRole()
                )
        );
    }
}

