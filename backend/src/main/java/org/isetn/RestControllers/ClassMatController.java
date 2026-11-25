package org.isetn.RestControllers;

import org.isetn.entities.ClassMat;
import org.isetn.entities.Classe;
import org.isetn.entities.Matiere;
import org.isetn.repository.ClassMatRepository;
import org.isetn.repository.ClasseRepository;
import org.isetn.repository.MatiereRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/classmats")
@CrossOrigin(origins = "*")
public class ClassMatController {

    @Autowired
    private ClassMatRepository classMatRepository;

    @Autowired
    private ClasseRepository classeRepository;

    @Autowired
    private MatiereRepository matiereRepository;

    @GetMapping
    public List<ClassMat> getAllClassMats() {
        return classMatRepository.findAll();
    }

    @GetMapping("/classe/{codClass}")
    public List<ClassMat> getByClasse(@PathVariable("codClass") Integer codClass) {
        return classMatRepository.findByClasseCodClass(codClass);
    }

    @GetMapping("/classe/{codClass}/matiere/{codMat}")
    public ClassMat getByClasseAndMatiere(
            @PathVariable("codClass") Integer codClass,
            @PathVariable("codMat") String codMat) {
        return classMatRepository.findByClasseCodClassAndMatiereCodMat(codClass, codMat).orElse(null);
    }

    @PostMapping
    public ClassMat saveOrUpdateClassMat(@RequestBody ClassMat incoming) {
        if (incoming.getClasse() == null || incoming.getClasse().getCodClass() == null
                || incoming.getMatiere() == null || incoming.getMatiere().getCodMat() == null) {
            throw new IllegalArgumentException("Classe codClass and Matiere codMat are required");
        }

        Integer codClass = incoming.getClasse().getCodClass();
        String codMat = incoming.getMatiere().getCodMat();

        Classe classe = classeRepository.findById(codClass)
                .orElseThrow(() -> new IllegalArgumentException("Classe not found: " + codClass));
        Matiere matiere = matiereRepository.findById(codMat)
                .orElseThrow(() -> new IllegalArgumentException("Matiere not found: " + codMat));

        Optional<ClassMat> existing = classMatRepository.findByClasseCodClassAndMatiereCodMat(codClass, codMat);
        ClassMat target = existing.orElseGet(ClassMat::new);
        target.setClasse(classe);
        target.setMatiere(matiere);
        target.setCoef(incoming.getCoef());
        target.setChsm(incoming.getChsm());
        return classMatRepository.save(target);
    }

    @DeleteMapping("/{id}")
    public void deleteClassMat(@PathVariable("id") Integer id) {
        classMatRepository.deleteById(id);
    }
}
