process LONGRANGER_ALIGN {
    // To use in cluster mode, some extra configurations is needed.
    // Visit tests/modules/longranger/align/nextflow.config for an example.

    tag "$meta.id"
    label 'process_high'

    def version = '2.2.2-c4'

    container "gitlab-registry.internal.sanger.ac.uk/tol-it/software/docker-images/longranger:2.2.2-c4"

    input:
    tuple val(meta), path(reference)
    path(fastqs)

    output:
    tuple val(meta), path("${meta.id}/outs/possorted_bam.bam"), emit: bam
    tuple val(meta), path("${meta.id}/outs/possorted_bam.bam.bai"), emit: bai
    tuple val(meta), path("${meta.id}/outs/summary.csv"), emit: csv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def sample = "${meta.id}"
    """
    longranger align --id=$sample --fastqs=$fastqs \
        --sample=$sample --reference=$reference \
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        longranger: \$(longranger align --version | grep longranger | sed 's/.*(//' | sed 's/).*//')
    END_VERSIONS
    """
}
