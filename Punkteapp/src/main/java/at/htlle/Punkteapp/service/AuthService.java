package at.htlle.Punkteapp.service;

import at.htlle.Punkteapp.config.JwtService;
import at.htlle.Punkteapp.domain.User;
import at.htlle.Punkteapp.dtos.AuthRes;
import at.htlle.Punkteapp.dtos.LoginReq;
import at.htlle.Punkteapp.dtos.RegisterReq;
import at.htlle.Punkteapp.repositories.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final UserRepository users;
    private final PasswordEncoder enc;
    private final JwtService jwt;

    public AuthService(UserRepository u, PasswordEncoder e, JwtService j){
        users=u; enc=e; jwt=j;
    }

    public AuthRes register(RegisterReq req, boolean admin){
        if (users.findByEmail(req.email()).isPresent()) throw new IllegalArgumentException("Email already used");
        var u = new User();
        u.setFirstname(req.firstname()); u.setLastname(req.lastname());
        u.setEmail(req.email()); u.setPassword(enc.encode(req.password()));
        u.setRole(admin? true:false); u.setPoints(0);
        users.save(u);
        var token = jwt.generate(u.getEmail(), String.valueOf(u.getRole()));
        return new AuthRes(token, u.getUserId(), u.getRole(), u.getPoints(), u.getFirstname(), u.getLastname(), u.getEmail());
    }

    public AuthRes login(LoginReq req){
        var u = users.findByEmail(req.email()).orElseThrow(()->new IllegalArgumentException("Invalid credentials"));
        if (!enc.matches(req.password(), u.getPassword())) throw new IllegalArgumentException("Invalid credentials");
        var token = jwt.generate(u.getEmail(), String.valueOf(u.getRole()));
        return new AuthRes(token, u.getUserId(), u.getRole(), u.getPoints(), u.getFirstname(), u.getLastname(), u.getEmail());
    }
}