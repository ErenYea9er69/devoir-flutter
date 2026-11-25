package org.isetn.entities;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "classe")
public class Classe {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cod_class")
    private Integer codClass;

    @Column(name = "nom_class")
    private String nomClass;

    @Column(name = "nbr_etud")
    private Integer nbrEtud;

    @ManyToOne
    @JoinColumn(name = "departement_cod_dept")
    private Departement departement;

    public Classe(String nomClass) {
        this.nomClass = nomClass;
    }

    public Classe(String nomClass, Integer nbrEtud, Departement departement) {
        this.nomClass = nomClass;
        this.nbrEtud = nbrEtud;
        this.departement = departement;
    }
}
