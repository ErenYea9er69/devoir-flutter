package org.isetn.entities;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "departement")
public class Departement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "cod_dept")
    private Integer codDept;

    @Column(name = "nom_dept")
    private String nomDept;

    public Departement(String nomDept) {
        this.nomDept = nomDept;
    }
}
