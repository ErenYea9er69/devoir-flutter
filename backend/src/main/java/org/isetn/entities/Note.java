package org.isetn.entities;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "note")
public class Note {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "etudiant_id")
    private Etudiant etudiant;

    @ManyToOne
    @JoinColumn(name = "cod_mat")
    private Matiere matiere;

    private Double tp1;
    private Double tp2;
    private Double ds;
    private Double exam;

    public Note(Etudiant etudiant, Matiere matiere, Double tp1, Double tp2, Double ds, Double exam) {
        this.etudiant = etudiant;
        this.matiere = matiere;
        this.tp1 = tp1;
        this.tp2 = tp2;
        this.ds = ds;
        this.exam = exam;
    }

    public Double getMoyenne() {
        double t1 = (tp1 != null) ? tp1 : 0.0;
        double t2 = (tp2 != null) ? tp2 : 0.0;
        double d = (ds != null) ? ds : 0.0;
        double e = (exam != null) ? exam : 0.0;
        return (t1 + t2 + d + e) / 4.0;
    }
}
