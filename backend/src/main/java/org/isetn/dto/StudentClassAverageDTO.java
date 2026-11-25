package org.isetn.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class StudentClassAverageDTO {
    private String nce;
    private String nom;
    private String prenom;
    private Double moyenne;
}
