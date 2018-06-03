############################################################
### BASIC CONFIGURATION ###
# This script is shared by all subsequent simulations
# Required variables:
# * PHASE - phase name ["minimize"|"warm"|"run"]
# * FIRST_STEP - first time step (default: 0)
# * STEPS - number of steps to run (not in warm)
# * THERMOSTAT - use thermostat [0/1] (default: 1)
# * BAROSTAT - use barostat [0/1] (default: 1)
# * PME - use PME [{x, y, z}]
############################################################

if {! [info exists THERMOSTAT]} {
    set THERMOSTAT 1
}
if {! [info exists BAROSTAT]} {
    set BAROSTAT 1
}
if {! [info exists PME]} {
    set PME 1
}

############################################################
# ELECTROSTATICS
############################################################
# Electrostatic - PME
# IMPORTANT: Disabling PME during minimization phase causes invalid minimization, leaving some atoms, especially
# hydrogens, close to each other.
if [info exists PME] {
    pme "on"
    pmegridspacing 1.0
}

############################################################
# MINIMIZATION
############################################################
if {$PHASE == "minimize"} {
    minimize $STEPS
    reinitvels 0

    # And we are done
    exit
}


############################################################
# WARM
############################################################
if {$PHASE == "warm"} {
    # Warm the system by reassigning velocities
    # number of steps between reinitiation of velocities
    reassignfreq 1000
    # initial temperature
    reassigntemp 0
    # target temperature
    reassignhold $TEMPERATURE
    # temperature step
    reassignincr 10

    run [expr $TEMPERATURE * 100 - $FIRST_STEP]

    # And we are done
    exit
}

### From this point is regular run
# Temperature control
if $THERMOSTAT {
    langevin "on"
    langevindamping 1
    langevintemp $TEMPERATURE
    langevinhydrogen "no"
}

# Pressure control
# IMPORTANT: This can not be turned on during warm phase as it causes simulation destruction. Probably because the
# piston has different temperature than the system has.
if $BAROSTAT {
    # smaller fluctuations
    usegrouppressure "yes"
    # allow dimensions to fluctuate independently
    useflexiblecell "yes"
    langevinpiston "on"
    langevinpistontarget 1.01325
    langevinpistonperiod 200.
    langevinpistondecay 100.
    langevinpistontemp $TEMPERATURE
}

# Ready, set, go :)
run [expr $STEPS - $FIRST_STEP]
