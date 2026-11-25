package org.isetn.entities;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "matiere")
public class Matiere {
    @Id
    @Column(name = "cod_mat")
    private String codMat;

    @Column(name = "int_mat")
    private String intMat;

    private String description;

    private String type; // e.g. "Cours" or "TP"

    public Matiere(String codMat, String intMat) {
        this.codMat = codMat;
        this.intMat = intMat;
    }
}
