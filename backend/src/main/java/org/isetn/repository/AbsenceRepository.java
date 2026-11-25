package org.isetn.repository;

import org.isetn.dto.AbsenceSummaryDTO;
import org.isetn.entities.Absence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AbsenceRepository extends JpaRepository<Absence, Integer> {
    List<Absence> findByEtudiantNce(String nce);
    List<Absence> findByEtudiantId(Integer etudiantId);

    @Query("SELECT new org.isetn.dto.AbsenceSummaryDTO(a.matiere.codMat, SUM(a.nha)) " +
           "FROM Absence a WHERE a.etudiant.nce = :nce GROUP BY a.matiere.codMat")
    List<AbsenceSummaryDTO> getAbsenceSummaryByNce(@Param("nce") String nce);
}
