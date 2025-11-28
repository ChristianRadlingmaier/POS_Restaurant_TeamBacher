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

    private Users me(){
        var auth = SecurityContextHolder.getContext().getAuthentication();
        var email = (String) auth.getPrincipal();
        return users.findByEmail(email).orElseThrow();
    }

    // Home: aktueller User & Punkte
    @GetMapping("/me")
    public Map<String,Object> meInfo(){
        var u=me();
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
    public Map<String,String> redeem(@RequestBody RewardRedeemReq req){
        points.redeem(me().getUserId(), req.rewardId());
        return Map.of("status","ok");
    }

    // Invoice anlegen (zum Punkte gutschreiben – z.B. Admin-Scan oder Testbutton)
    @PostMapping("/invoices")
    public Map<String,Object> addInvoice(@RequestBody InvoiceCreateReq req){
        var inv = points.addInvoice(me().getUserId(), req.pointsEarned());
        return Map.of("invoiceId",inv.getInvoiceId(),"date",inv.getDate(),"pointsEarned",inv.getPointsEarned());
    }

    // Transaktionshistorie (optional)
    @GetMapping("/history")
    public List<HistoryItemDTO> history(){ return points.timeline(me().getUserId()); }

    // Profil speichern (ProfilePage)
    @PutMapping("/profile")
    public Map<String,String> update(@RequestBody UpdateProfileReq req){
        var u = me();
        if(req.firstname()!=null) u.setFirstname(req.firstname());
        if(req.lastname()!=null)  u.setLastname(req.lastname());
        if(req.email()!=null)     u.setEmail(req.email());
        if(req.password()!=null && !req.password().isBlank()) u.setPassword(enc.encode(req.password()));
        users.save(u);
        return Map.of("status","ok");
    }
}