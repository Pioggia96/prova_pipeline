/* include { SALMON_VIRAL } from '../modules/salmon_viral'

workflow QUANTIFICATION {
    take: 
    unmapped_reads
    salmon_index_channel
    project_name // <-- New input

    main:
    // L'indice di Salmon è unico → usiamo .combine
    // Il combine si aspetta la tupla con le sole reads non mappate.
    // quant_input = unmapped_reads.combine(salmon_index_channel)
    quant = SALMON_VIRAL(quant_input) 
    SALMON_VIRAL(unmapped_reads, salmon_index_channel, project_name)

    emit:
    quant_res = quant
} */

include { SALMON_VIRAL } from '../modules/salmon_viral'

workflow QUANTIFICATION {

    take:
    unmapped_reads_channel
    salmon_index

    main:
    salmon_input = unmapped_reads_channel.map { sample_id, project_name, virus, r1, r2 ->
        tuple(sample_id, project_name, r1, r2)
    }

    salmon_out = SALMON_VIRAL(salmon_input, salmon_index)

    emit:
    quant_res = salmon_out
}

