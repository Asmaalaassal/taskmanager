package com.ticketmanager.service;

import com.ticketmanager.dto.AuthResponse;
import com.ticketmanager.dto.CreateAgentRequest;
import com.ticketmanager.dto.LoginRequest;
import com.ticketmanager.dto.RegisterRequest;
import com.ticketmanager.dto.UserResponse;
import com.ticketmanager.entity.ProblemType;
import com.ticketmanager.entity.Role;
import com.ticketmanager.entity.User;
import com.ticketmanager.exception.ResourceNotFoundException;
import com.ticketmanager.repository.ProblemTypeRepository;
import com.ticketmanager.repository.UserRepository;
import com.ticketmanager.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService implements UserDetailsService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final ProblemTypeRepository problemTypeRepository;

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));

        return org.springframework.security.core.userdetails.User.builder()
                .username(user.getEmail())
                .password(user.getPassword())
                .authorities(Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + user.getRole().name())))
                .build();
    }

    @Transactional(readOnly = true)
    public User findByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
    }

    @Transactional(readOnly = true)
    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    }

    public AuthResponse login(LoginRequest request) {
        User user = findByEmail(request.getEmail());

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        String token = jwtUtil.generateToken(user.getEmail());
        return new AuthResponse(token, user.getEmail(), user.getName(), user.getRole());
    }

    @Transactional
    public UserResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(Role.USER);

        User savedUser = userRepository.save(user);
        return mapToUserResponse(savedUser);
    }

    @Transactional
    public UserResponse createAgent(CreateAgentRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        User agent = new User();
        agent.setName(request.getName());
        agent.setEmail(request.getEmail());
        agent.setPassword(passwordEncoder.encode(request.getPassword()));
        agent.setRole(Role.AGENT);

        // Set specializations
        Set<ProblemType> specializations = request.getSpecializationIds().stream()
                .map(id -> problemTypeRepository.findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("Problem type not found with id: " + id)))
                .collect(Collectors.toSet());
        agent.setSpecializations(specializations);

        User savedAgent = userRepository.save(agent);
        return mapToUserResponse(savedAgent);
    }

    @Transactional(readOnly = true)
    public List<UserResponse> getAllAgents() {
        return userRepository.findByRole(Role.AGENT).stream()
                .map(this::mapToUserResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public UserResponse getAgentById(Long id) {
        User agent = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Agent not found with id: " + id));
        if (agent.getRole() != Role.AGENT) {
            throw new RuntimeException("User is not an agent");
        }
        return mapToUserResponse(agent);
    }

    public UserResponse getCurrentUser(String email) {
        User user = findByEmail(email);
        return mapToUserResponse(user);
    }

    private UserResponse mapToUserResponse(User user) {
        return new UserResponse(user.getId(), user.getName(), user.getEmail(), user.getRole());
    }
}

