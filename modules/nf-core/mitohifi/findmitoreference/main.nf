process MITOHIFI_FINDMITOREFERENCE {
    secret 'NCBI_API_KEY'

    tag '$species'
    label 'process_low'

    container 'ghcr.io/marcelauliano/mitohifi:master'

    input:
    val species
    val email
    val min_length

    output:
    path "*.fasta",                 emit: fasta
    path "*.gb",                    emit: gb
    path "versions.yml",            emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    findMitoReference.py \\
        --species $species \\
        --email $email \\
        --min_length $min_length \\
        --outfolder . \\
        --ncbi-api-key \${NCBI_API_KEY}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mitohifi: \$( mitohifi.py --version 2>&1 | head -n1 | sed 's/^.*MitoHiFi //; s/ .*\$//' )
    END_VERSIONS
    """

    stub:
    """
    touch accession.fasta
    touch accession.gb

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        mitohifi: \$( mitohifi.py --version 2>&1 | head -n1 | sed 's/^.*MitoHiFi //; s/ .*\$//' )
    END_VERSIONS
    """
}
