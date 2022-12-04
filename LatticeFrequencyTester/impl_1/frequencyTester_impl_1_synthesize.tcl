if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/3.2} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "C:/Users/jzales/Desktop/E155FinalProject/E155FinalProject/LatticeFrequencyTester"
# synthesize IPs
# synthesize VMs
# synthesize top design
file delete -force -- frequencyTester_impl_1.vm frequencyTester_impl_1.ldc
run_engine_newmsg synthesis -f "frequencyTester_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o frequencyTester_impl_1_syn.udb frequencyTester_impl_1.vm] "C:/Users/jzales/Desktop/E155FinalProject/E155FinalProject/LatticeFrequencyTester/impl_1/frequencyTester_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
