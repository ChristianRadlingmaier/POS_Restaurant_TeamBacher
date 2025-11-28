package at.htlle.Punkteapp.service;

import at.htlle.Punkteapp.domain.History;
import at.htlle.Punkteapp.domain.Invoice;
import at.htlle.Punkteapp.dtos.HistoryItemDTO;
import at.htlle.Punkteapp.repositories.HistoryRepository;
import at.htlle.Punkteapp.repositories.InvoiceRepository;
import at.htlle.Punkteapp.repositories.RewardRepository;
import at.htlle.Punkteapp.repositories.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Stream;

@Service
public class PointsService {
    private final UserRepository users;
    private final InvoiceRepository invoices;
    private final RewardRepository rewards;
    private final HistoryRepository history;

    public PointsService(UserRepository u, InvoiceRepository i, RewardRepository r, HistoryRepository h){
        users=u; invoices=i; rewards=r; history=h;
    }

    @Transactional
    public Invoice addInvoice(Long userId, int pointsEarned){
        var u = users.findById(userId).orElseThrow();
        var inv = new Invoice();
        inv.setUser(u); inv.setDate(LocalDateTime.now()); inv.setPointsEarned(pointsEarned);
        invoices.save(inv);
        u.addPoints(pointsEarned);
        return inv;
    }

    @Transactional
    public void redeem(Long userId, Long rewardId){
        var u = users.findById(userId).orElseThrow();
        var r = rewards.findById(rewardId).orElseThrow();
        if (!"ACTIVE".equalsIgnoreCase(String.valueOf(Optional.ofNullable(r.getStatus()).orElse(true))))
            throw new IllegalStateException("Reward inactive");
        var cost = Optional.ofNullable(r.getPointsCost()).orElse(0);
        if (Optional.ofNullable(u.getPoints()).orElse(0) < cost)
            throw new IllegalStateException("Not enough points");

        u.addPoints(-cost);
        var h = new History();
        h.setUser(u); h.setReward(r); h.setDate(LocalDateTime.now());
        history.save(h);
    }

    @Transactional(readOnly = true)
    public List<HistoryItemDTO> timeline(Long userId){
        var earn = invoices.findByUser_UserIdOrderByDateDesc(userId).stream()
                .map(i -> new HistoryItemDTO("EARN", "Invoice #"+i.getInvoiceId(), i.getPointsEarned(), i.getDate()))
                .toList();
        var red = history.findByUser_UserIdOrderByDateDesc(userId).stream()
                .map(h -> new HistoryItemDTO("REDEEM", h.getReward().getTitle(), -h.getReward().getPointsCost(), h.getDate()))
                .toList();
        return Stream.concat(earn.stream(), red.stream())
                .sorted(Comparator.comparing(HistoryItemDTO::date).reversed())
                .toList();
    }
}