package org.isetn.RestControllers;

import org.isetn.entities.Matiere;
import org.isetn.repository.MatiereRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/matieres")
@CrossOrigin(origins = "*")
public class MatiereController {

    @Autowired
    private MatiereRepository matiereRepository;

    @GetMapping
    public List<Matiere> getAllMatieres() {
        return matiereRepository.findAll();
    }

    @PostMapping
    public Matiere createMatiere(@RequestBody Matiere matiere) {
        return matiereRepository.save(matiere);
    }

    @PutMapping("/{codMat}")
    public Matiere updateMatiere(@PathVariable("codMat") String codMat, @RequestBody Matiere matiere) {
        matiere.setCodMat(codMat);
        return matiereRepository.save(matiere);
    }

    @DeleteMapping("/{codMat}")
    public void deleteMatiere(@PathVariable("codMat") String codMat) {
        matiereRepository.deleteById(codMat);
    }
}
