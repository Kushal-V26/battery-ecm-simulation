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

<p align="center">
  <img src="results/discharge_curve_0.5C.png" width="45%" />
  <img src="results/discharge_curve_1.0C.png" width="45%" />
</p>

---

### 2. HPPC Test & Parameter Identification
Evaluates dynamic voltage relaxation during current pulses and extracts internal ohmic resistance ($R_0$):

<p align="center">
  <img src="results/hppc_profile.png" width="45%" />
  <img src="results/r0_extraction.png" width="45%" />
</p>

---

### 3. Dynamic Drive-Cycle SOC Estimation (EKF vs. Open-Loop)
Tests estimation performance against measurement noise ($\sigma = 2\text{ mV}$) and an intentional **10% initial SOC bias** ($SOC_0 = 80\%$ estimated vs. $90\%$ true):

<p align="center">
  <img src="results/soc_estimation_comparison.png" width="60%" />
</p>

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

# Li-ion Battery 1RC Thevenin ECM Simulation & SOC Estimation

A MATLAB simulation framework for a representative **NMC 18650 Li-ion cell (2.0 Ah)**. It models battery voltage behavior, extracts circuit parameters using HPPC pulse data, and accurately tracks State of Charge (SOC) using an Extended Kalman Filter (EKF).

---

## 📌 Key Highlights

- **1RC Equivalent Circuit Model (ECM)**: Simulates open-circuit voltage (Voc), internal ohmic resistance (R0), and transient RC diffusion dynamics (R1, C1).
- **Automated Parameter Extraction**: Identifies internal resistance and polarization parameters from HPPC pulse test data.
- **Robust SOC Estimation (EKF)**: Corrects for initial state errors and sensor noise, outperforming standard Coulomb Counting.

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

## ⚙️ How It Works (Simplified)

### 1. Battery Modeling (1RC Thevenin Model)
The battery terminal voltage is calculated from three components:
$$\text{Terminal Voltage } (V_t) = V_{\text{oc}}(\text{SOC}) - V_{\text{polarization}} - (I \times R_0)$$
- **$V_{\text{oc}}(\text{SOC})$**: Baseline open-circuit voltage determined by remaining battery charge.
- **$I \times R_0$**: Instantaneous voltage drop across internal ohmic resistance.
- **$V_{\text{polarization}}$**: Transient exponential voltage response modeled by a parallel $R_1 C_1$ circuit.

### 2. State of Charge Tracking (EKF vs. Coulomb Counting)
- **Coulomb Counting (Open-Loop)** integrates current over time. Any initial error or sensor drift remains permanently uncorrected.
- **Extended Kalman Filter (Closed-Loop)** continuously compares the predicted terminal voltage with simulated sensor measurements to dynamically correct SOC errors.

---

## 📊 Results & Validation

### Parameter Extraction
- **Nominal $R_0$**: `0.0200 Ω` | **Extracted $R_0$**: `0.0200 Ω` (0.00% Error)
- **Nominal $R_1$**: `0.0150 Ω` | **Nominal $C_1$**: `2000.0 F` ($\tau = 30.0\text{ s}$)

### SOC Estimation Performance (Dynamic Drive Cycle)
Tested with **2 mV sensor noise** and an intentional **10% initial offset** ($\text{SOC}_0 = 80\%$ estimated vs. $90\%$ true):

| Method | Initial Bias | Final RMSE | Convergence Time |
|---|---|---|---|
| **Coulomb Counting** | 10.0% | **10.00%** | Never recovers |
| **Extended Kalman Filter (EKF)** | 10.0% | **0.45%** | **< 60 seconds** |

---

## 🚀 Getting Started

### Prerequisites
- MATLAB R2020b or later

### Running the Project
1. Clone the repository:
   ```bash
   git clone [https://github.com/Kushal-V26/proov-km-waechter-fix.git](https://github.com/Kushal-V26/proov-km-waechter-fix.git)
   cd proov-km-waechter-fix
   ```
2. Open MATLAB and run:
   ```matlab
   main_run_all_tests
   ```
3. All plots and log files will automatically save to the `results/` folder.

---

## 📄 License
Distributed under the MIT License.

---


   ```
4. All generated figures, diagnostic output, and test metrics will update directly in the `/results` directory.
