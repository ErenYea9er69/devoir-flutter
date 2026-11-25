package org.isetn.repository;

import org.isetn.entities.ClassMat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClassMatRepository extends JpaRepository<ClassMat, Integer> {
    List<ClassMat> findByClasseCodClass(Integer codClass);
    Optional<ClassMat> findByClasseCodClassAndMatiereCodMat(Integer codClass, String codMat);
}
