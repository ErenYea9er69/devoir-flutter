package org.isetn.entities;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "etudiant")
public class Etudiant {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "nce", unique = true)
    private String nce;

    private String nom;
    private String prenom;

    @Column(name = "date_nais")
    private String dateNais;

    @Column(name = "lieu_nais")
    private String lieuNais;

    @Column(name = "nbre_etud")
    private Integer nbreEtud;

    @ManyToOne
    @JoinColumn(name = "classe_cod_class")
    private Classe classe;

    public Etudiant(String nom, String prenom, String dateNais, Integer nbreEtud, Classe classe) {
        this.nom = nom;
        this.prenom = prenom;
        this.dateNais = dateNais;
        this.nbreEtud = nbreEtud;
        this.classe = classe;
    }

    public Etudiant(String nce, String nom, String prenom, String dateNais, String lieuNais, Classe classe) {
        this.nce = nce;
        this.nom = nom;
        this.prenom = prenom;
        this.dateNais = dateNais;
        this.lieuNais = lieuNais;
        this.classe = classe;
    }
}
