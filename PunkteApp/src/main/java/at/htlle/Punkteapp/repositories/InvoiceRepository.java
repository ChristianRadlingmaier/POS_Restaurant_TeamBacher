package at.htlle.Punkteapp.repositories;

import at.htlle.Punkteapp.domain.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InvoiceRepository extends JpaRepository<Invoice,Long> {
    List<Invoice> findByUser_UserIdOrderByDateDesc(Long userId);
}
