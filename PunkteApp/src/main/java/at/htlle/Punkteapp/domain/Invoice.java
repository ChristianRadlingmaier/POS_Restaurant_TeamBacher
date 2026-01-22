package at.htlle.Punkteapp.domain;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity @Table(name="Invoice")
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="InvoiceID") private Long invoiceId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="UserID", nullable=false)
    private Users user;

    @Column(name="Date")
    private LocalDateTime date;

    @Column(name="PointsEarned")
    private Integer pointsEarned;

    public Invoice() {}

    public Long getInvoiceId() { return invoiceId; }
    public void setInvoiceId(Long invoiceId) { this.invoiceId = invoiceId; }

    public Users getUser() { return user; }
    public void setUser(Users user) { this.user = user; }

    public LocalDateTime getDate() { return date; }
    public void setDate(LocalDateTime date) { this.date = date; }

    public Integer getPointsEarned() { return pointsEarned; }
    public void setPointsEarned(Integer pointsEarned) { this.pointsEarned = pointsEarned; }
}