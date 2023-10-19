package com.ips.ipsManager.Security;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.servlet.HandlerExceptionResolver;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Autowired
    private JwtService jwtService;
    @Autowired 
    private UserDetailsImplementation userDetailsImple;
    private HandlerExceptionResolver handlerExceptionResolver;

    public JwtAuthenticationFilter (HandlerExceptionResolver handlerException){
        this.handlerExceptionResolver=handlerException;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            String jwtToken = "";
            String username;

            // getting the token from the headers
            String authToken = request.getHeader("Authorization");

            if (authToken == null || !authToken.startsWith("Bearer ")) {
                filterChain.doFilter(request, response);
                return;
            }
            // extract the token from authToken
            jwtToken = authToken.substring(7);
            // extracting username from token
            username = jwtService.extractUsername(jwtToken);
   
            
            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                UserDetails userDetails = userDetailsImple.loadUserByUsername(username);
         

                if (jwtService.isTokenValid(userDetails,jwtToken)) {
                    UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(userDetails,
                            null, userDetails.getAuthorities());
                    auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(auth);

                }

            }
            filterChain.doFilter(request, response);

        } catch (Exception e) {
            handlerExceptionResolver.resolveException(request, response, null, e);
         
        }

    }

}
