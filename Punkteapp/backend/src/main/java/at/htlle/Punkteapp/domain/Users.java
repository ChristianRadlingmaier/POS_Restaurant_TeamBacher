package at.htlle.Punkteapp.domain;

import jakarta.persistence.Entity;
import jakarta.persistence.*;

@Entity
@Table(name = "Users")
public class Users {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="UserID") private Long userId;

    @Column(name="Firstname")
    private String firstname;

    @Column(name="Lastname")
    private String lastname;

    @Column(name="Password")
    private String password;

    @Column(name="Role")
    private boolean role;

    @Column(name="Email", unique = true)
    private String email;

    @Column(name="Points")
    private Integer points = 0;

    public void addPoints(int delta){
        this.points = (this.points==null?0:this.points)+delta;
    }

    // ---- Getter / Setter
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getFirstname() { return firstname; }
    public void setFirstname(String firstname) { this.firstname = firstname; }

    public String getLastname() { return lastname; }
    public void setLastname(String lastname) { this.lastname = lastname; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public Boolean getRole() { return role; }
    public void setRole(Boolean role) { this.role = role; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Integer getPoints() { return points; }
    public void setPoints(Integer points) { this.points = points; }
}
