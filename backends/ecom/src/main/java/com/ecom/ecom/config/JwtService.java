package com.ecom.ecom.models;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;

@Service
public class JwtService {
    private final String SECRET = "Ef09upJbh0gSouoC51L9+Lzzgfq4oJG6b7xBK+Yhs4rNZVuGXu541StOS4l1r9IU";


    public String extractUsername(String token) {
        return "";
    }

    private <T> Claim  extractClaim(String token , Function claimResolver){
        Claims claims=extractAllClaims(token);
       return claimResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts
                .parser()
                .setSigningKey(getKey())
                .parseClaimsJws(token)
                .getBody();
    }

    public String generateToken(Map<String, Object> claims, UserDetails userDetails) {

        return Jwts
                .builder()
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 24))
                .setSubject(userDetails.getUsername())
                .setClaims(claims)
                .signWith(SignatureAlgorithm.HS256, getKey())
                .compact();

    }

    private Key getKey() {
        byte[] bytes =;

      return K
    }
}
