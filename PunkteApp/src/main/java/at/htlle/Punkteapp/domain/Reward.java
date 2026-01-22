package at.htlle.Punkteapp.domain;
import jakarta.persistence.*;

@Entity @Table(name="Reward")
public class Reward {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="RewardID")
    private Long rewardId;

    @Column(name="Title")
    private String title;

    @Column(name="Status")
    private boolean status;

    @Column(name="Description")
    private String description;

    @Column(name="PointsCost")
    private Integer pointsCost;

    public Reward() {}

    public Long getRewardId() { return rewardId; }
    public void setRewardId(Long rewardId) { this.rewardId = rewardId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Boolean getStatus() { return status; }
    public void setStatus(Boolean status) { this.status = status; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Integer getPointsCost() { return pointsCost; }
    public void setPointsCost(Integer pointsCost) { this.pointsCost = pointsCost; }
}