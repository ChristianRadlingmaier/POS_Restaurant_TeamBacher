package at.htlle.Punkteapp.web;

import at.htlle.Punkteapp.domain.Reward;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import at.htlle.Punkteapp.repositories.RewardRepository;
import at.htlle.Punkteapp.repositories.UserRepository;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final UserRepository users; private final RewardRepository rewards;
    public AdminController(UserRepository u, RewardRepository r){ users=u; rewards=r; }

    @GetMapping("/users")
    public List<Map<String, Object>> allUsers() {
        return users.findAll().stream()
                .map(u -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("userId", u.getUserId());
                    map.put("name", u.getFirstname() + " " + u.getLastname());
                    map.put("email", u.getEmail());
                    map.put("role", u.getRole());
                    map.put("points", u.getPoints());
                    return map;
                })
                .toList();
    }

    @PutMapping("/users/{id}/points")
    public Map<String,String> setPoints(@PathVariable Long id, @RequestParam int points){
        var u=users.findById(id).orElseThrow(); u.setPoints(points); users.save(u);
        return Map.of("status","ok");
    }

    @PostMapping("/rewards")
    public Reward create(@RequestBody Reward r){
        return rewards.save(r);
    }

    @PutMapping("/rewards/{id}")
    public Reward update(@PathVariable Long id, @RequestBody Reward r){
        var db = rewards.findById(id).orElseThrow();
        db.setTitle(r.getTitle()); db.setDescription(r.getDescription());
        db.setStatus(r.getStatus()); db.setPointsCost(r.getPointsCost());
        return rewards.save(db);
    }

    @DeleteMapping("/rewards/{id}")
    public void delete(@PathVariable Long id){
        rewards.deleteById(id);
    }
}