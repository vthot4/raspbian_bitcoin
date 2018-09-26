#!/bin/bash
###########################################################################################
##      
##      Author:  dlightning team
##      Project: dlightning 
##      Version: v0.2 (genesis)
##
##########################################################################################
#  
# Source: https://www.funtoo.org/Raspberry_Pi_Userland_(VCGENCMD)
# 
### 

section_head()
{
    echo ""
    echo " $1"
    echo " =================================="
    echo " "
}

help(){
    echo " "
    echo $"Usage: $0 {frecuency|volts|temp|config|mem|version}"
    echo " "
    echo "  all             Show all parameters"
    echo "  frequency       Print frecuency of all clocks: arm, core, h264, isp, v3d, uart, pwm, emmc, pixel, vec, hdmi, dpi." 
    echo "  volts           Print voltage of code, sdram_c, sdram_i, sdram_p."
    echo "  temp            Shows core temperature of BCM2835 SoC"
    echo "  config          Print the initial configuration"
    echo "  mem             Shows how much memory is split between the CPU(arm) and GPU."
    echo "  outmem          Reports statics on Out of Memory events"
    echo "  version         Shows the firmware version"
    echo " "
}

all_clocks_frecuency()
{
    ## Print frecuency of all clocks: arm, core, h264, isp, v3d, uart, pwm, emmc, pixel, vec, hdmi, dpi.
    section_head "Frecuency of all clocks:"
    items="arm core h264 isp v3d uart pwm emmc pixel vec hdmi dpi"
    for i in $items; do
        echo -e "   $i:\t$(vcgencmd measure_clock $i)"
    done 
    echo " "
}

all_measure_volts()
{
    ## Print voltage of code, sdram_c, sdram_i, sdram_p.
    section_head " Voltage of some components:"
    items="core sdram_c sdram_i sdram_p"

    for i in $items; do 
        echo -e "   $i:\t$(vcgencmd measure_volts $i)" ;
    done
    echo ""
}

measure_temp()
{
    ## Shows core temperature of BCM2835 SoC
    section_head " Core temperature of BCM2835"
    vcgencmd measure_temp
    echo ""
}

get_init_config()
{
    ## Print the initial configuration
    section_head " Configuration"
    vcgencmd get_config int
    echo " "
}

get_mem()
{
    ## Shows how much memory is split between the CPU(arm) and GPU.
    section_head "Memory split (arm/gpu)"
    vcgencmd get_mem arm && vcgencmd get_mem gpu
    echo ""
}
get_outmemory()
    ## Reports statics on Out of Memory events
    section_head "Statics on Out of Memory events"
    vcgencmd mem_oom
    echo " "

get_version()
{
    # Shows the firmware version
    section_head "Firmware version"
    vcgencmd version
    echo ""   
}

case "$1" in
    frequency)
        all_clocks_frecuency
        ;;
    volts)
        all_measure_volts
        ;;
    temp)
        measure_temp
        ;;
    config)
        get_init_config
        ;;
    mem)
        get_mem
        ;;
    outmem)
        get_outmemory
        ;;
    version)
        get_version
        ;;
    all)
        all_clocks_frecuency
        all_measure_volts
        measure_temp
        get_init_config
        get_mem
        get_version
        ;;
    *)
        help
esac
