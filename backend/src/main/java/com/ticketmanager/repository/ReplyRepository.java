package com.ticketmanager.repository;

import com.ticketmanager.entity.Reply;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReplyRepository extends JpaRepository<Reply, Long> {
    List<Reply> findByTicketIdOrderByCreatedAtAsc(Long ticketId);
}

