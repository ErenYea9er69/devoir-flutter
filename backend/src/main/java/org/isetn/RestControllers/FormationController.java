package org.isetn.RestControllers;

import org.isetn.entities.Formation;
import org.isetn.repository.FormationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/formations")
@CrossOrigin(origins = "*")
public class FormationController {

    @Autowired
    private FormationRepository formationRepository;

    @GetMapping
    public List<Formation> getAllFormations() {
        return formationRepository.findAll();
    }

    @PostMapping
    public Formation createFormation(@RequestBody Formation formation) {
        return formationRepository.save(formation);
    }

    @DeleteMapping("/{id}")
    public void deleteFormation(@PathVariable("id") Integer id) {
        formationRepository.deleteById(id);
    }
}
