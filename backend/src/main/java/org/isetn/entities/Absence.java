package org.isetn.entities;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "absence")
public class Absence {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "cod_mat")
    private Matiere matiere;

    @ManyToOne
    @JoinColumn(name = "etudiant_id")
    private Etudiant etudiant;

    @Column(name = "date_a")
    private String dateA;

    @Column(name = "nha")
    private Double nha;

    public Absence(Matiere matiere, Etudiant etudiant, String dateA, Double nha) {
        this.matiere = matiere;
        this.etudiant = etudiant;
        this.dateA = dateA;
        this.nha = nha;
    }
}
