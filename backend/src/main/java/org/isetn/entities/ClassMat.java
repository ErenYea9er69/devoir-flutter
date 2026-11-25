package org.isetn.entities;

import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "class_mat")
public class ClassMat {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "cod_mat")
    private Matiere matiere;

    @ManyToOne
    @JoinColumn(name = "cod_class")
    private Classe classe;

    private Double coef;
    private Double chsm;
}
