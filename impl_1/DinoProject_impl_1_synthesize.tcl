if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/3.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/mathe/Downloads/dinoFinal-20211222T174150Z-001/dinoFinal"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- DinoProject_impl_1_cpe.ldc
run_engine_newmsg cpe -f "DinoProject_impl_1.cprj" "mypll.cprj" "player.cprj" "dino_1.cprj" "dinodino.cprj" "CactusSprite.cprj" "DinoDead.cprj" -a "iCE40UP" -o DinoProject_impl_1_cpe.ldc
# synthesize top design
file delete -force -- DinoProject_impl_1.vm DinoProject_impl_1.ldc
run_engine_newmsg synthesis -f "DinoProject_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o DinoProject_impl_1_syn.udb DinoProject_impl_1.vm] "C:/Users/mathe/Downloads/dinoFinal-20211222T174150Z-001/dinoFinal/impl_1/DinoProject_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
