############################################################
### BASIC CONFIGURATION ###
# This script is shared by all subsequent simulations
# Required variables:
# * INPUT_PREFIX - if not first simulation
# * BINARY_INPUT - if input files are binary [0/1] (default: 0)
# * OUTPUT_PREFIX
# * OUTPUT_FREQ - all output frequences (default: 1000)
# * PHASE - phase name ["minimize"|"warm"|"run"]
# * FIRST_STEP - first time step (default: 0)
############################################################

############################################################
# CONSTANTS AND DEFAULTS
############################################################
# 273 K = 0 C
set TEMPERATURE 310
set FORCE_FIELD "charmm"
if {! [info exists FIRST_STEP]} {
    set FIRST_STEP 0
}
if {! [info exists BINARY_INPUT]} {
    set BINARY_INPUT 0
}
if {! [info exists OUTPUT_FREQ]} {
    set OUTPUT_FREQ 1000
}


############################################################
# FORCE FIELD DEFINITION
############################################################
if {$FORCE_FIELD == "amber"} {
    # Amber force field
    amber "yes"
    parmfile "$PARM_PREFIX.prmtop"
    # read 1-4 exclusions from parmfile
    readexclusions "yes"
    # dividing of 1-4 vdw interactions
    scnb 2.0
} elseif {$FORCE_FIELD == "charmm"} {
    # CHARMM force field
    paratypecharmm "on"
    parameters "../../par_all27_prot_lipid_na.inp"
    structure "$PARM_PREFIX.psf"
} else {
    puts "environment.tcl: Unknown force field $FORCE_FIELD"
    exit 1
}

if {$FORCE_FIELD == "amber"} {
    # Default cutoff for AMBER if 8.0
    cutoff 10.
    # No switching in AMBER
    switching "off"
    pairlistdist 13.5
    # ignored if readexclusions == yes
    exclude "scaled1-4"
    # ==1/1.2 multiplying of 1-4 electrostatic interactions
    1-4scaling 0.833333
} else {
    # These are extracted from topology file
    cutoff 12.0
    switching "on"
    switchdist 10.0
    pairlistdist 14.0
    exclude "scaled1-4"
    1-4scaling 1.0
}


############################################################
# INPUT
############################################################
if [info exists INPUT_PREFIX] {
    # Coordinates
    if $BINARY_INPUT {
        bincoordinates "$INPUT_PREFIX.coor"
        if {$FORCE_FIELD == "amber"} {
            ambercoor "$PARM_PREFIX.inpcrd"
        } else {
            coordinates "$PARM_PREFIX.pdb"
        }
    } else {
        coordinates "$INPUT_PREFIX.coor"
    }
    # Velocities
    if {$PHASE != "warm"} {
        if $BINARY_INPUT {
            binvelocities "$INPUT_PREFIX.vel"
        } else {
            velocities "$INPUT_PREFIX.vel"
        }
    } else {
        temperature 0
    }
    # Boundaries
    extendedsystem "$INPUT_PREFIX.xsc"
} else {
    temperature 0
}


############################################################
# OUTPUT
############################################################
outputname $OUTPUT_PREFIX
binaryoutput "off"
restartfreq $OUTPUT_FREQ
dcdfreq $OUTPUT_FREQ
xstfreq $OUTPUT_FREQ
outputenergies $OUTPUT_FREQ
outputpressure $OUTPUT_FREQ
outputtiming $OUTPUT_FREQ
# Wrap coordinates around boundaries
wrapwater "on"
wrapall "on"


############################################################
# DYNAMICS
############################################################
# Timesteps
firsttimestep $FIRST_STEP
timestep 1
nonbondedfreq 2
fullelectfrequency 4
stepspercycle 20
# Rigidity
# No rigid bonds
