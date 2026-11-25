package org.isetn.repository;

import org.isetn.entities.Classe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClasseRepository extends JpaRepository<Classe, Integer> {
    List<Classe> findByDepartementCodDept(Integer codDept);
}
