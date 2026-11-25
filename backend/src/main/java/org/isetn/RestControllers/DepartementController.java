package org.isetn.RestControllers;

import org.isetn.entities.Departement;
import org.isetn.repository.DepartementRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/departements")
@CrossOrigin(origins = "*")
public class DepartementController {

    @Autowired
    private DepartementRepository departementRepository;

    @GetMapping
    public List<Departement> getAllDepartements() {
        return departementRepository.findAll();
    }

    @PostMapping
    public Departement createDepartement(@RequestBody Departement departement) {
        return departementRepository.save(departement);
    }
}
