package at.htlle.Punkteapp.web;

import at.htlle.Punkteapp.dtos.AuthRes;
import at.htlle.Punkteapp.dtos.LoginReq;
import at.htlle.Punkteapp.dtos.RegisterReq;
import at.htlle.Punkteapp.service.AuthService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService auth;
    public AuthController(AuthService a){ this.auth=a; }

    @PostMapping("/register")
    public AuthRes register(@RequestBody RegisterReq req){
        return auth.register(req,false);
    }

    @PostMapping("/register-admin") public AuthRes registerAdmin(@RequestBody RegisterReq req){
        return auth.register(req,true);
    }

    @PostMapping("/login") public AuthRes login(@RequestBody LoginReq req){
        return auth.login(req);
    }
}