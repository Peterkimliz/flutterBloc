package com.ips.ipsManager.Security;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
@Service

public class JwtService {

    static final String SECRETKEY = "404E635266556A586E3272357538782F413F4428472B4B6250645367566B5970";

    // extract username
    public String extractUsername(String token) {
        return extractSingleClaim(token, Claims::getSubject);
    }

    /// extract singleClaim
    private <T> T extractSingleClaim(String token, Function<Claims, T> claimsResolver) {
        Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // extractAllClaims
    private Claims extractAllClaims(String token) {
    
        return Jwts
                .parserBuilder()
                .setSigningKey(getSignInKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
    // generate token without passing claims

    public String buildToken(UserDetails userDetails) {
        return buildToken(userDetails, new HashMap<>());
    }

    // generate token
    public String buildToken(UserDetails userDetails, Map<String, Object> claims) {
        return Jwts
                .builder()
                .setClaims(claims)
                .setSubject(userDetails.getUsername())
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 24))
                .signWith(getSignInKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    // check if toke n is valid
    public boolean isTokenValid(UserDetails userDetails, String token) {
         String username = extractUsername(token);
        return (userDetails.getUsername().equals(username) && !tokenExpired(token));
    }

    // check if token is expired
    private boolean tokenExpired(String token) {
        return extractExpiration(token).before(new Date(System.currentTimeMillis()));
    }
    // extract expiration date of a token

    private Date extractExpiration(String token) {
       return extractSingleClaim(token, Claims::getExpiration);
    }

    private Key getSignInKey() {
    byte[] keyBytes = Decoders.BASE64.decode(SECRETKEY);
    return Keys.hmacShaKeyFor(keyBytes);
  }


}
