# Li-ion Battery 1RC Thevenin ECM Simulation & SOC Estimation

Simulation and estimation framework for a representative **NMC 18650 cell (2.0 Ah)** using a 1RC Thevenin Equivalent Circuit Model (ECM), automated parameter extraction (HPPC), and Extended Kalman Filter (EKF) State of Charge (SOC) estimation.

---

## 📁 Repository Structure

```text
├── src/
│   ├── simulateBatteryECM.m        # 1RC ECM forward simulation engine
│   ├── generateHPPCProfile.m       # Hybrid Pulse Power Characterization current profile
│   ├── extractECMParameters.m      # Automated R0, R1, C1 parameter extraction
│   ├── generateDriveCycleProfile.m # Dynamic drive-cycle current profile generator
│   ├── ocvSocLookup.m             # Open-circuit voltage vs. SOC relationship
│   └── socEKF.m                    # Extended Kalman Filter implementation
├── results/
│   ├── discharge_curve_0.5C.png    # Constant-current discharge profile (0.5C)
│   ├── discharge_curve_1.0C.png    # Constant-current discharge profile (1.0C)
│   ├── hppc_profile.png            # HPPC current/voltage test curves
│   ├── r0_extraction.png           # Extracted series resistance R0 vs. true value
│   ├── soc_estimation_comparison.png # EKF vs. Coulomb Counting tracking
│   ├── test_output.log             # Simulation console log
│   └── test_results.txt            # Parameter extraction and RMSE logs
├── main_run_all_tests.m            # Main execution test suite
└── README.md
