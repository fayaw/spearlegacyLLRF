# Math Rendering Test — Equation Numbering Approaches

## Test 1: \qquad \text{} approach (PREFERRED)
```math
E = mc^2 \qquad \text{(Eq. 1)}
```

## Test 2: \qquad \text{} with sub-label
```math
E = mc^2 \qquad \text{(Eq. 2.1a)}
```

## Test 3: \qquad \text{} with boxed equation
```math
\boxed{f_{c,\text{max}} \approx \frac{1}{4\tau_d}} \qquad \text{(Eq. 3)}
```

## Test 4: \qquad \text{} with matrix
```math
\begin{pmatrix} I_\text{out} \\ Q_\text{out} \end{pmatrix} = G \begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix} \begin{pmatrix} I_\text{in} \\ Q_\text{in} \end{pmatrix} \qquad \text{(Eq. 4)}
```

## Test 5: \tag{} approach (for comparison — may break on GitHub)
```math
E = mc^2 \tag{Eq. 5}
```

## Test 6: No label (standalone below)
```math
E = mc^2
```
**(Eq. 6)**
