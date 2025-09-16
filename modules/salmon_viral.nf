// modules/salmon_viral.nf
process SALMON_VIRAL {

    tag "${sample_id}"
    publishDir "${params.outdir}/${project_name}/salmon_viral", mode: 'copy'

    errorStrategy 'ignore'   // <--- questa riga permette di continuare

    input:
    tuple val(sample_id), val(project_name), path(r1), path(r2)
    path salmon_index

    output:
    tuple val(sample_id), val(project_name), path("${sample_id}_quant.sf"), emit: quant_res

    script:
    """
    salmon quant \
        -i ${salmon_index} \
        -l A \
        -1 ${r1} -2 ${r2} \
        --validateMappings \
        -p ${task.cpus} \
        -o ${sample_id}_salmon_out || true   # <--- opzionale, forza exit 0

    cp ${sample_id}_salmon_out/quant.sf ${sample_id}_quant.sf || touch ${sample_id}_quant.sf
    """
}
