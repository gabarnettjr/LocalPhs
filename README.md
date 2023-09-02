# LocalPhs
Local high-dimensional interpolation using Polyharmonic Spline (PHS) Radial Basis functions (RBFs)
## Object Descriptions
### Matrix.pm
An object of type "Matrix" can be created in multiple ways.
* Matrix::new()
* Matrix::zeros()
  * numRows
  * numCols
* Matrix::ones()
  * numRows
  * numCols
* Matrix::eye()
  * numRows (numRows and numCols are the same for an identity matrix)
* Matrix::linspace()
  * Minimum value
  * Maximum value
  * Number of steps

Every object of type "Matrix" has three attributes.
* items
* numRows
* numCols
### Phs.pm
An object of type "Phs" requires 4 variables for initialization.
* RBF exponent (1, 3, 5, ...)
* Polynomial degree (0, 1)
* Nodes ($n \times d$ matrix)
* Function values ($n \times 1$ matrix)
### LocalPhs.pm
An object of type "LocalPhs" requires 5 variables for initialization.
* RBF exponent (1, 3, 5, ...)
* Maximum polynomial degree (0, 1)
* Nodes ($n \times d$ matrix)
* Function values ($n \times 1$ matrix)
* Stencil radius (real number)
