package org.isetn.repository;

import org.isetn.entities.Note;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NoteRepository extends JpaRepository<Note, Integer> {
    List<Note> findByEtudiantNce(String nce);
    List<Note> findByEtudiantClasseCodClass(Integer codClass);
}
