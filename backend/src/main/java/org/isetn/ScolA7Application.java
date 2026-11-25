package org.isetn;

import org.isetn.entities.*;
import org.isetn.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.util.Arrays;

@SpringBootApplication
public class ScolA7Application {

    public static void main(String[] args) {
        SpringApplication.run(ScolA7Application.class, args);
    }

    @Bean
    CommandLineRunner start(
            UserRepository userRepository,
            RoleRepository roleRepository,
            DepartementRepository departementRepository,
            ClasseRepository classeRepository,
            EtudiantRepository etudiantRepository,
            MatiereRepository matiereRepository,
            AbsenceRepository absenceRepository,
            NoteRepository noteRepository,
            FormationRepository formationRepository) {
        return args -> {
            if (userRepository.count() == 0) {
                Role adminRole = roleRepository.save(new Role("ADMIN"));
                Role userRole = roleRepository.save(new Role("USER"));

                User u1 = new User("admin@gmail.com", "admin");
                u1.setRoles(Arrays.asList(adminRole, userRole));
                userRepository.save(u1);

                User u2 = new User("foulen@gmail.com", "foulen");
                u2.setRoles(Arrays.asList(userRole));
                userRepository.save(u2);
            }

            Departement dTI = null;
            if (departementRepository.count() == 0) {
                dTI = departementRepository.save(new Departement("TI"));
            } else {
                dTI = departementRepository.findAll().get(0);
            }

            Classe c1 = null;
            Classe c5 = null;
            if (classeRepository.count() == 0) {
                c1 = classeRepository.save(new Classe("DSI21", 20, dTI));
                classeRepository.save(new Classe("DSI22", 22, dTI));
                classeRepository.save(new Classe("DSI23", 24, dTI));
                classeRepository.save(new Classe("DSI31", 25, dTI));
                c5 = classeRepository.save(new Classe("DSI33", 25, dTI));
            } else {
                c5 = classeRepository.findAll().stream()
                        .filter(c -> "DSI33".equals(c.getNomClass()))
                        .findFirst()
                        .orElse(classeRepository.findAll().get(0));
                c1 = classeRepository.findAll().get(0);
            }

            Etudiant e1 = null;
            if (etudiantRepository.count() == 0) {
                e1 = etudiantRepository.save(new Etudiant("E1", "Ben Foulen1", "Foulen1", "2001-05-12", "Nabeul", c5));
                etudiantRepository.save(new Etudiant("E2", "Ben Ali", "Mohamed", "2001-05-12", "Tunis", c5));
                etudiantRepository.save(new Etudiant("E3", "Trabelsi", "Sarra", "2002-09-20", "Sousse", c5));
                etudiantRepository.save(new Etudiant("E4", "Gharbi", "Ahmed", "2001-11-03", "Sfax", c5));
                etudiantRepository.save(new Etudiant("E5", "Foulen", "Ben Foulen", "2002-01-15", "Nabeul", c1));
                etudiantRepository.save(new Etudiant("E6", "Hammami", "Youssef", "2002-03-25", "Bizerte", c1));
                etudiantRepository.save(new Etudiant("E7", "Jlassi", "Arij", "2001-07-18", "Monastir", c5));
                etudiantRepository.save(new Etudiant("E8", "Kacem", "Sami", "2002-12-05", "Kairouan", c1));
                etudiantRepository.save(new Etudiant("E9", "Mejri", "Ines", "2001-10-14", "Ariana", c5));
                etudiantRepository.save(new Etudiant("E10", "Zouari", "Aymen", "2002-08-09", "Sfax", c1));
            } else {
                e1 = etudiantRepository.findByNce("E1").orElse(etudiantRepository.findAll().get(0));
            }

            Matiere mAFCP = null;
            Matiere mSOA = null;
            if (matiereRepository.count() == 0) {
                mAFCP = matiereRepository.save(new Matiere("AFCP", "Atelier Framework Cross-Platform", "Flutter and Spring", "TP"));
                mSOA = matiereRepository.save(new Matiere("SOA", "Architecture Orientée Services", "Web Services and REST", "Cours"));
                matiereRepository.save(new Matiere("MOBILE", "Développement Mobile", "Android Native", "TP"));
            } else {
                mAFCP = matiereRepository.findById("AFCP").orElse(null);
                mSOA = matiereRepository.findById("SOA").orElse(null);
            }

            if (absenceRepository.count() == 0 && e1 != null && mAFCP != null && mSOA != null) {
                absenceRepository.save(new Absence(mAFCP, e1, "11-11-2025", 1.5));
                absenceRepository.save(new Absence(mAFCP, e1, "04-10-2025", 4.5));
                absenceRepository.save(new Absence(mSOA, e1, "20-10-2025", 1.5));
                absenceRepository.save(new Absence(mSOA, e1, "23-10-2025", 3.0));
                absenceRepository.save(new Absence(mSOA, e1, "16-10-2025", 3.0));

                Etudiant e2 = etudiantRepository.findByNce("E2").orElse(null);
                if (e2 != null) {
                    absenceRepository.save(new Absence(mAFCP, e2, "05-11-2025", 3.0));
                    absenceRepository.save(new Absence(mSOA, e2, "12-11-2025", 1.5));
                }

                Etudiant e5 = etudiantRepository.findByNce("E5").orElse(null);
                if (e5 != null) {
                    absenceRepository.save(new Absence(mAFCP, e5, "01-11-2025", 4.5));
                }
            }

            if (noteRepository.count() == 0 && e1 != null && mAFCP != null && mSOA != null) {
                noteRepository.save(new Note(e1, mAFCP, 15.0, 14.0, 16.0, 15.0));
                noteRepository.save(new Note(e1, mSOA, 12.0, 13.0, 14.0, 15.0));

                Etudiant e2 = etudiantRepository.findByNce("E2").orElse(null);
                if (e2 != null) {
                    noteRepository.save(new Note(e2, mAFCP, 10.0, 12.0, 11.0, 13.0));
                    noteRepository.save(new Note(e2, mSOA, 14.0, 15.0, 12.0, 13.0));
                }

                Etudiant e3 = etudiantRepository.findByNce("E3").orElse(null);
                if (e3 != null) {
                    noteRepository.save(new Note(e3, mAFCP, 16.0, 17.0, 18.0, 17.0));
                    noteRepository.save(new Note(e3, mSOA, 15.0, 16.0, 17.0, 16.0));
                }

                Etudiant e4 = etudiantRepository.findByNce("E4").orElse(null);
                if (e4 != null) {
                    noteRepository.save(new Note(e4, mSOA, 13.0, 12.0, 14.0, 11.0));
                }
            }

            if (formationRepository.count() == 0) {
                formationRepository.save(new Formation("Mobile Development (Flutter)", 30));
                formationRepository.save(new Formation("Web REST APIs (Spring Boot)", 45));
                formationRepository.save(new Formation("Cloud & DevOps", 20));
            }
        };
    }
}
