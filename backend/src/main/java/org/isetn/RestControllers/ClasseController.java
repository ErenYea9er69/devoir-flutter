package org.isetn.RestControllers;

import org.isetn.entities.Classe;
import org.isetn.entities.Etudiant;
import org.isetn.repository.ClasseRepository;
import org.isetn.repository.EtudiantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/classes")
@CrossOrigin(origins = "*")
public class ClasseController {

    @Autowired
    private ClasseRepository classeRepository;

    @Autowired
    private EtudiantRepository etudiantRepository;

    @GetMapping
    public List<Classe> getAllClasses() {
        return classeRepository.findAll();
    }

    @GetMapping("/dept/{codDept}")
    public List<Classe> getClassesByDept(@PathVariable("codDept") Integer codDept) {
        return classeRepository.findByDepartementCodDept(codDept);
    }

    @PostMapping
    public Classe createClasse(@RequestBody Classe classe) {
        return classeRepository.save(classe);
    }

    @PutMapping("/{id}")
    public Classe updateClasse(@PathVariable("id") Integer id, @RequestBody Classe classe) {
        classe.setCodClass(id);
        return classeRepository.save(classe);
    }

    @GetMapping("/{id}/etudiants")
    public List<Etudiant> getStudentsByClass(@PathVariable("id") Integer id) {
        return etudiantRepository.findByClasseCodClass(id);
    }

    @DeleteMapping("/{id}")
    public void deleteClasse(@PathVariable("id") Integer id) {
        classeRepository.deleteById(id);
    }
}
