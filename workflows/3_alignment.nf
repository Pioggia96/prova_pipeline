include { STAR_ALIGN_HUMAN } from '../modules/star_align_human'

workflow ALIGNMENT {
    take:
    trimmed_reads

    main:
    // Canale dell'indice STAR
    def star_genome_channel = Channel.fromPath(params.star_idx)

    // Lancia STAR con i due canali separati
    star_out = STAR_ALIGN_HUMAN(
        trimmed_reads.map { sample_id, project_name, virus, r1, r2 ->
            tuple(sample_id, project_name, virus, r1, r2)
        },
        star_genome_channel
    )

    emit:
    star_results = star_out.star_results
}
