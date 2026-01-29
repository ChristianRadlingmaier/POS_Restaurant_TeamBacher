package at.htlle.Punkteapp.repositories;

import at.htlle.Punkteapp.domain.History;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HistoryRepository extends JpaRepository<History,Long> {
    List<History> findByUser_UserIdOrderByDateDesc(Long userId);
}


/**
 * 
 * Spring Data JPA Namenskonvention
 * 
 * 
 *   SELECT * FROM History h
 *   JOIN Users u ON h.user_id = u.user_id
 *   WHERE u.user_id = ?
 *   ORDER BY h.date DESC
 */
