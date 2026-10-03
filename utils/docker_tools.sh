#!/usr/bin/env bash
# Shared helpers for running SynthStrip and SynthSeg via Docker, so
# run_saline and run_elecnet don't each install their own copy of this
# logic. Sourced, not executed.
#
# Images:
#   SynthStrip: https://hub.docker.com/r/freesurfer/synthstrip
#   SynthSeg:   https://hub.docker.com/r/cookpa/synthseg

SYNTHSTRIP_DOCKER_IMAGE="${SYNTHSTRIP_DOCKER_IMAGE:-freesurfer/synthstrip:1.8}"
SYNTHSEG_DOCKER_IMAGE="${SYNTHSEG_DOCKER_IMAGE:-cookpa/synthseg:conda-0.2}"

docker_available() {
    command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1
}

# run_synthstrip_docker <input> <stripped_out> <mask_out>
run_synthstrip_docker() {
    local input="$1" stripped_out="$2" mask_out="$3"
    local dir
    dir="$(cd -- "$(dirname -- "$input")" && pwd)"
    docker run --rm -u "$(id -u):$(id -g)" -v "${dir}:${dir}" \
        "$SYNTHSTRIP_DOCKER_IMAGE" \
        -i "$input" -o "$stripped_out" -m "$mask_out"
}

# run_synthseg_docker <input> <seg_out> [threads]
run_synthseg_docker() {
    local input="$1" seg_out="$2" threads="${3:-5}"
    local dir
    dir="$(cd -- "$(dirname -- "$input")" && pwd)"
    docker run --rm -u "$(id -u):$(id -g)" -v "${dir}:${dir}" \
        "$SYNTHSEG_DOCKER_IMAGE" \
        --i "$input" --o "$seg_out" --threads "$threads" --cpu
}
