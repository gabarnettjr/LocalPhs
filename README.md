# LocalPhs
Perform local high-dimensional interpolation using Polyharmonic Spline (PHS) Radial Basis functions (RBFs).
## Object Descriptions
### Matrix.pm
An object of type "Matrix" can be created in many ways.y
* Matrix::new()
* Matrix::zeros()
* Matrix::ones()
* Matrix::eye()
* Matrix::linspace()
### Phs.pm
An object of type "Phs" must be given the following variables upon creation.
* RBF exponent (1, 3, 5, ...)
* Polynomial degree (0, 1)
* Nodes ($n \times d$ matrix)
* Function values ($n \times 1$ matrix)
