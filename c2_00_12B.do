/* NOTE: Program (macro) PBIS must be run first for this do-file to function */


capture close

use /trainee/jrhull/diss/ch2/c2data/c2_00_12


/* Corr's with h_pf_00 */

pwcorr h_pf_00 hg_rss00, sig
pbis   h_pf_00 hg_rss00

pwcorr h_pf_00 hg_ros00, sig
pbis   h_pf_00 hg_ros00

pwcorr h_pf_00 hg_ris00, sig
pbis   h_pf_00 hg_ris00

pwcorr h_pf_00 h00spcnt, sig
pbis   h_pf_00 h00spcnt

pwcorr h_pf_00 h00spavg, sig
pbis   h_pf_00 h00spavg


/* Corr's with h_pf_01 */

pwcorr h_pf_01 hg_rsr00, sig
pbis   h_pf_01 hg_rsr00

pwcorr h_pf_01 hg_rsr00, sig
pbis   h_pf_01 hg_ror00

pwcorr h_pf_01 hg_rir00, sig
pbis   h_pf_01 hg_rir00

pwcorr h_pf_01 hg_rss00, sig
pbis   h_pf_01 hg_rss00

pwcorr h_pf_01 hg_ros00, sig
pbis   h_pf_01 hg_ros00

pwcorr h_pf_01 hg_ris00, sig
pbis   h_pf_01 hg_ris00

pwcorr h_pf_01 h00rpcnt, sig
pbis   h_pf_01 h00rpcnt

pwcorr h_pf_01 h00rpavg, sig
pbis   h_pf_01 h00rpavg

pwcorr h_pf_01 h00spcnt, sig
pbis   h_pf_01 h00spcnt


/* Corr's with h_pf_11 */

pwcorr h_pf_11 hg_rsr00, sig
pbis   h_pf_11 hg_rsr00

pwcorr h_pf_11 hg_rsr00, sig
pbis   h_pf_11 hg_ror00

pwcorr h_pf_11 hg_rir00, sig
pbis   h_pf_11 hg_rir00

pwcorr h_pf_11 hg_rss00, sig
pbis   h_pf_11 hg_rss00

pwcorr h_pf_11 hg_ros00, sig
pbis   h_pf_11 hg_ros00

pwcorr h_pf_11 hg_ris00, sig
pbis   h_pf_11 hg_ris00

pwcorr h_pf_11 h00rpcnt, sig
pbis   h_pf_11 h00rpcnt

pwcorr h_pf_11 h00rpavg, sig
pbis   h_pf_11 h00rpavg

pwcorr h_pf_11 h00spcnt, sig
pbis   h_pf_11 h00spcnt

pwcorr h_pf_11 h00spavg, sig
pbis   h_pf_11 h00spavg


/* Corr's with h_pf_10 */

pwcorr h_pf_10 hg_rsr00, sig
pbis   h_pf_10 hg_rsr00

pwcorr h_pf_10 hg_rsr00, sig
pbis   h_pf_10 hg_ror00

pwcorr h_pf_10 hg_rir00, sig
pbis   h_pf_10 hg_rir00

pwcorr h_pf_10 hg_rss00, sig
pbis   h_pf_10 hg_rss00

pwcorr h_pf_10 hg_ros00, sig
pbis   h_pf_10 hg_ros00

pwcorr h_pf_10 hg_ris00, sig
pbis   h_pf_10 hg_ris00

pwcorr h_pf_10 h00rpcnt, sig
pbis   h_pf_10 h00rpcnt

pwcorr h_pf_10 h00rpavg, sig
pbis   h_pf_10 h00rpavg

pwcorr h_pf_10 h00spcnt, sig
pbis   h_pf_10 h00spcnt

pwcorr h_pf_10 h00spavg, sig
pbis   h_pf_10 h00spavg










