package org.isetn.RestControllers;

import org.isetn.dto.StudentClassAverageDTO;
import org.isetn.entities.Etudiant;
import org.isetn.entities.Note;
import org.isetn.repository.EtudiantRepository;
import org.isetn.repository.NoteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/notes")
@CrossOrigin(origins = "*")
public class NoteController {

    @Autowired
    private NoteRepository noteRepository;

    @Autowired
    private EtudiantRepository etudiantRepository;

    @GetMapping
    public List<Note> getAllNotes() {
        return noteRepository.findAll();
    }

    @GetMapping("/etudiant/{nce}")
    public List<Note> getNotesByEtudiantNce(@PathVariable("nce") String nce) {
        return noteRepository.findByEtudiantNce(nce);
    }

    @GetMapping("/classe/{codClass}")
    public List<Note> getNotesByClasse(@PathVariable("codClass") Integer codClass) {
        return noteRepository.findByEtudiantClasseCodClass(codClass);
    }

    @GetMapping("/classe/{codClass}/averages")
    public List<StudentClassAverageDTO> getClassAverages(@PathVariable("codClass") Integer codClass) {
        List<Etudiant> students = etudiantRepository.findByClasseCodClass(codClass);
        List<StudentClassAverageDTO> result = new ArrayList<>();

        for (Etudiant s : students) {
            List<Note> notes = noteRepository.findByEtudiantNce(s.getNce());
            double sumMoyennes = 0.0;
            int count = 0;

            for (Note n : notes) {
                sumMoyennes += n.getMoyenne();
                count++;
            }

            double overallMoyenne = (count > 0) ? (sumMoyennes / count) : 0.0;
            overallMoyenne = Math.round(overallMoyenne * 100.0) / 100.0;

            result.add(new StudentClassAverageDTO(s.getNce(), s.getNom(), s.getPrenom(), overallMoyenne));
        }

        return result;
    }

    @PostMapping
    public Note createNote(@RequestBody Note note) {
        return noteRepository.save(note);
    }

    @PutMapping("/{id}")
    public Note updateNote(@PathVariable("id") Integer id, @RequestBody Note note) {
        note.setId(id);
        return noteRepository.save(note);
    }

    @DeleteMapping("/{id}")
    public void deleteNote(@PathVariable("id") Integer id) {
        noteRepository.deleteById(id);
    }
}
