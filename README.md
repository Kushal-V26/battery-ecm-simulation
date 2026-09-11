# Li-ion Battery 1RC Thevenin ECM Simulation & SOC Estimation

Simulation and estimation framework for a representative **NMC 18650 cell (2.0 Ah)** using a 1RC Thevenin Equivalent Circuit Model (ECM), automated parameter extraction via Hybrid Pulse Power Characterization (HPPC), and Extended Kalman Filter (EKF) State of Charge (SOC) estimation.

---

## 📁 Repository Structure

```text
├── src/
│   ├── simulateBatteryECM.m        # 1RC ECM forward simulation engine
│   ├── generateHPPCProfile.m       # HPPC current profile generator
│   ├── extractECMParameters.m      # Automated R0, R1, C1 parameter extraction
│   ├── generateDriveCycleProfile.m # Dynamic drive-cycle current profile generator
│   ├── ocvSocLookup.m              # Open-circuit voltage vs. SOC relationship
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
```

---

## 📊 Simulation Results & Analysis

### 1. Constant-Current Discharge
Validates cell terminal voltage drop, internal resistance losses, and lower-cutoff behavior across different discharge rates:

#### 0.5C Discharge Rate
![0.5C Discharge](results/discharge_curve_0.5C.png)

#### 1.0C Discharge Rate
![1.0C Discharge](results/discharge_curve_1.0C.png)

---

### 2. HPPC Test & Parameter Identification
Evaluates dynamic voltage relaxation during current pulses and extracts internal ohmic resistance (R0):

#### HPPC Current & Voltage Profile
![HPPC Profile](results/hppc_profile.png)

#### Extracted R0 vs. Ground Truth
![R0 Extraction](results/r0_extraction.png)

---

### 3. Dynamic Drive-Cycle SOC Estimation (EKF vs. Open-Loop)
Tests estimation performance against measurement noise (std = 2 mV) and an intentional **10% initial SOC bias** (SOC0 = 80% estimated vs. 90% true):

![SOC Estimation Comparison](results/soc_estimation_comparison.png)

```text
============================================================
           BATTERY ECM & ESTIMATION TEST RESULTS
============================================================

1. Parameter Extraction Validation:
   - Nominal / True R0:  0.0200 Ohm
   - Extracted R0:       0.0200 Ohm (Error: 0.00 %)
   - Nominal / True R1:  0.0150 Ohm
   - Nominal / True C1:  2000.0 Farad (Tau = 30.0 s)

2. Dynamic Drive Cycle SOC Estimation:
   - Initial True SOC:      90.0 %
   - Initial Estimated SOC: 80.0 % (10.0 % deliberate initial offset)
   - Voltage Sensor Noise:  Gaussian White Noise (std = 2 mV)

3. Performance Comparison:
   - Coulomb Counting (Open-Loop) RMSE: 10.00 % SOC (bias never clears)
   - Extended Kalman Filter (EKF) RMSE:   0.45 % SOC (converges in < 60 s)
============================================================
```

---

## 🔬 Mathematical Formulation

### Equivalent Circuit Model Dynamics
The 1RC Thevenin model state equations are discretized using exact exponential zero-order hold:

- **State Equations:**
  $$\text{SOC}[k+1] = \text{SOC}[k] - \frac{\Delta t}{Q_{\text{cell}}} \cdot I[k]$$
  $$V_1[k+1] = \exp\left(-\frac{\Delta t}{R_1 C_1}\right) V_1[k] + R_1 \left(1 - \exp\left(-\frac{\Delta t}{R_1 C_1}\right)\right) I[k]$$

### Observation Equation & Linearization
The terminal voltage $V_t$ is computed from open-circuit voltage $V_{\text{oc}}$, polarization voltage $V_1$, and ohmic drop:

$$V_t[k] = V_{\text{oc}}(\text{SOC}[k]) - V_1[k] - I[k] \cdot R_0$$

The measurement Jacobian matrix $C_k$ is evaluated at each time step using numerical differentiation of the OCV-SOC lookup table:

$$C_k = \left. \begin{bmatrix} \frac{\partial V_{\text{oc}}}{\partial \text{SOC}} & -1 \end{bmatrix} \right|_{\hat{x}_{k|k-1}}$$

---

## 🚀 How to Run

1. Clone or download the repository.
2. Open MATLAB and navigate to the project root directory.
3. Run the complete test suite from the Command Window:
   ```matlab
   main_run_all_tests
   ```
4. All generated figures, diagnostic output, and test metrics will update directly in the `/results` directory.
