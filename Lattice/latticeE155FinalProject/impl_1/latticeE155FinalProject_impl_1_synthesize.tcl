if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/3.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/jzales/Desktop/E155FinalProject/E155FinalProject/Lattice/latticeE155FinalProject"
# synthesize IPs
# synthesize VMs
# synthesize top design
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o latticeE155FinalProject_impl_1_syn.udb latticeE155FinalProject_impl_1.vm] "C:/Users/jzales/Desktop/E155FinalProject/E155FinalProject/Lattice/latticeE155FinalProject/impl_1/latticeE155FinalProject_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
