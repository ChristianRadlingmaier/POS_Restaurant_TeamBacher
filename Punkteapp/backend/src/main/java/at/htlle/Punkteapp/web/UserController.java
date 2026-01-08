package at.htlle.Punkteapp.web;

import at.htlle.Punkteapp.domain.Users;
import at.htlle.Punkteapp.dtos.*;
import at.htlle.Punkteapp.repositories.RewardRepository;
import at.htlle.Punkteapp.repositories.UserRepository;
import at.htlle.Punkteapp.service.PointsService;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {
    private final UserRepository users;
    private final PointsService points;
    private final RewardRepository rewards;
    private final PasswordEncoder enc;

    public UserController(UserRepository u, PointsService p, RewardRepository r, PasswordEncoder e){
        users=u; points=p; rewards=r; enc=e; }


    private Users me(String email, String password){
        if (email == null || email.isBlank()) throw new IllegalArgumentException("Email required");
        if (password == null || password.isBlank()) throw new IllegalArgumentException("Password required");
        var u = users.findByEmail(email).orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));
        if (!enc.matches(password, u.getPassword())) throw new IllegalArgumentException("Invalid email or password");
        return u;
    }

    // Home: aktueller User & Punkte
    @GetMapping("/me")
    public Map<String,Object> meInfo(@RequestParam String email, @RequestParam String password){
        var u=me(email, password);
        return Map.of("userId",u.getUserId(),"firstname",u.getFirstname(),"lastname",u.getLastname(),
                "email",u.getEmail(),"points",u.getPoints(),"role",u.getRole());
    }

    // Rewards (für RewardsPage)
    @GetMapping("/rewards")
    public List<RewardDTO> listRewards(){
        return rewards.findAll().stream()
                .map(r->new RewardDTO(r.getRewardId(), r.getTitle(), r.getStatus(), r.getDescription(), r.getPointsCost()))
                .toList();
    }

    // Redeem (Button in RewardsPage)
    @PostMapping("/redeem")
    public Map<String,String> redeem(@RequestBody RewardRedeemReq req, @RequestParam String email, @RequestParam String password){
        points.redeem(me(email, password).getUserId(), req.rewardId());
        return Map.of("status","ok");
    }

    // Invoice anlegen (zum Punkte gutschreiben – z.B. Admin-Scan oder Testbutton)
    @PostMapping("/invoices")
    public Map<String,Object> addInvoice(@RequestBody InvoiceCreateReq req, @RequestParam String email, @RequestParam String password){
        var inv = points.addInvoice(me(email, password).getUserId(), req.pointsEarned());
        return Map.of("invoiceId",inv.getInvoiceId(),"date",inv.getDate(),"pointsEarned",inv.getPointsEarned());
    }

    // Transaktionshistorie (optional)
    @GetMapping("/history")
    public List<HistoryItemDTO> history(@RequestParam String email, @RequestParam String password){ return points.timeline(me(email, password).getUserId()); }

    // Profil speichern (ProfilePage)
    @PutMapping("/profile")
    public Map<String,String> update(@RequestBody UpdateProfileReq req, @RequestParam String email, @RequestParam String password){
        var u = me(email, password);
        if(req.firstname()!=null) u.setFirstname(req.firstname());
        if(req.lastname()!=null)  u.setLastname(req.lastname());
        if(req.email()!=null)     u.setEmail(req.email());
        if(req.password()!=null && !req.password().isBlank()) u.setPassword(enc.encode(req.password()));
        users.save(u);
        return Map.of("status","ok");
    }
}