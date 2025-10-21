package at.htlle.Punkteapp.domain;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name="History")
public class History {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="HistoryID") private Long historyId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="UserID", nullable=false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="RewardID", nullable=false) // beim Einlösen referenziert
    private Reward reward;

    @Column(name="Date")
    private LocalDateTime date;

    public History() {}

    public Long getHistoryId() { return historyId; }
    public void setHistoryId(Long historyId) { this.historyId = historyId; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public Reward getReward() { return reward; }
    public void setReward(Reward reward) { this.reward = reward; }

    public LocalDateTime getDate() { return date; }
    public void setDate(LocalDateTime date) { this.date = date; }
}