package org.isetn.RestControllers;

import org.isetn.dto.AbsenceSummaryDTO;
import org.isetn.entities.Absence;
import org.isetn.repository.AbsenceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/absences")
@CrossOrigin(origins = "*")
public class AbsenceController {

    @Autowired
    private AbsenceRepository absenceRepository;

    @GetMapping
    public List<Absence> getAllAbsences() {
        return absenceRepository.findAll();
    }

    @GetMapping("/etudiant/{nce}")
    public List<Absence> getAbsencesByEtudiantNce(@PathVariable("nce") String nce) {
        return absenceRepository.findByEtudiantNce(nce);
    }

    @GetMapping("/summary/{nce}")
    public List<AbsenceSummaryDTO> getAbsenceSummaryByNce(@PathVariable("nce") String nce) {
        return absenceRepository.getAbsenceSummaryByNce(nce);
    }

    @PostMapping
    public Absence createAbsence(@RequestBody Absence absence) {
        return absenceRepository.save(absence);
    }

    @PutMapping("/{id}")
    public Absence updateAbsence(@PathVariable("id") Integer id, @RequestBody Absence absence) {
        absence.setId(id);
        return absenceRepository.save(absence);
    }

    @DeleteMapping("/{id}")
    public void deleteAbsence(@PathVariable("id") Integer id) {
        absenceRepository.deleteById(id);
    }
}
