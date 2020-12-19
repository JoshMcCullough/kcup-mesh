#!/usr/bin/env bash

if ! command -v openscad &> /dev/null; then
	echo 'OpenSCAD binary not found on path.'
	exit -1
fi

fileExists() {
	if [ "${force}" != true ] && [ -f "${1}" ]; then
		echo "File ${file} exists but '-f' flag not set -- skipping."

		true
	else
		false
	fi
}

# read params
while test $# != 0; do
	case "$1" in
		-f) force=true ;;
		-o) outDir=$2; shift ;;
		*) extraOptions="${extraOptions} $1" ;;
	esac

	shift
done

outDir=${outDir:=out/stl}
options="--hardwarnings --check-parameters true --check-parameter-ranges true ${extraOptions} ./kcup-mesh.scad"

for x in {1..4}; do
	for y in {1..4}; do
		if [ "${x}" == 2 ] && [ "${y}" == 1 ]; then
			continue
		else
			file="${outDir}/kcup-mesh_${x}x${y}.stl"

			echo

			if ! fileExists ${file}; then
				echo "Generating ${x}x${y} K-Cup holder..."
				openscad -o ${file} -D 'action="holder"' -D "x=${x}" -D "y=${y}" ${options}
			fi
		fi
	done
done