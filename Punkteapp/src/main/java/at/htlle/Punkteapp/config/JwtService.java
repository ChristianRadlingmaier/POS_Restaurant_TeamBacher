package at.htlle.Punkteapp.config;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.util.Date;

@Service
public class JwtService {
    @Value("${app.jwt.secret}") private String secret;
    public String generate(String subject, String role){
        return Jwts.builder()
                .setSubject(subject).claim("role", role)
                .setIssuedAt(new Date())
                .setExpiration(Date.from(Instant.now().plus(Duration.ofDays(7))))
                .signWith(Keys.hmacShaKeyFor(secret.getBytes()), SignatureAlgorithm.HS256)
                .compact();
    }
    public String subject(String token){
        return Jwts.parser().setSigningKey(secret.getBytes()).build()
                .parseClaimsJws(token).getBody().getSubject();
    }
}