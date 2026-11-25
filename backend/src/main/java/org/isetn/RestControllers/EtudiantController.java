package org.isetn.RestControllers;

import org.isetn.entities.Etudiant;
import org.isetn.repository.EtudiantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/etudiants")
@CrossOrigin(origins = "*")
public class EtudiantController {

    @Autowired
    private EtudiantRepository etudiantRepository;

    @GetMapping
    public List<Etudiant> getAllEtudiants() {
        return etudiantRepository.findAll();
    }

    @GetMapping("/classe/{codClass}")
    public List<Etudiant> getEtudiantsByClasse(@PathVariable("codClass") Integer codClass) {
        return etudiantRepository.findByClasseCodClass(codClass);
    }

    @PostMapping
    public Etudiant createEtudiant(@RequestBody Etudiant etudiant) {
        return etudiantRepository.save(etudiant);
    }

    @DeleteMapping("/{id}")
    public void deleteEtudiant(@PathVariable("id") Integer id) {
        etudiantRepository.deleteById(id);
    }
}
