package at.htlle.Punkteapp.web;

import at.htlle.Punkteapp.dtos.AuthRes;
import at.htlle.Punkteapp.dtos.LoginReq;
import at.htlle.Punkteapp.dtos.RegisterReq;
import at.htlle.Punkteapp.service.AuthService;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
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

    // Login via URL: /api/auth/login?email=...&password=...
    @GetMapping(value = "/login", params = {"email", "password"})
    public AuthRes loginViaUrl(@RequestParam String email, @RequestParam String password){
        return auth.login(new LoginReq(email, password));
    }

    // Register via URL: http://localhost:8080/api/auth/login?email=hihi&password=1234
    @GetMapping(value = "/register", params = {"firstname", "lastname", "email", "password"})
    public AuthRes registerViaUrl(@RequestParam String firstname,
                                  @RequestParam String lastname,
                                  @RequestParam String email,
                                  @RequestParam String password){
        return auth.register(new RegisterReq(firstname, lastname, email, password), false);
    }

    // Register-Admin via URL: localhost:8080/api/auth/register?firstname=nene&lastname=pepe&email=hihi&password=1234
    @GetMapping(value = "/register-admin", params = {"firstname", "lastname", "email", "password"})
    public AuthRes registerAdminViaUrl(@RequestParam String firstname,
                                       @RequestParam String lastname,
                                       @RequestParam String email,
                                       @RequestParam String password){
        return auth.register(new RegisterReq(firstname, lastname, email, password), true);
    }
}