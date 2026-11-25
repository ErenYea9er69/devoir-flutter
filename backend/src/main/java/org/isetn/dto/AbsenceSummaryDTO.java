package org.isetn.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AbsenceSummaryDTO {
    private String codMat;
    private Double totalNha;
}
