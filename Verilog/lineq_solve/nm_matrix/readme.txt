===============================================================================
================== EE 454 Predictor-Corrector Implementation ==================
============================== mn_matrix module ===============================
===============================================================================

Designed by Anta Imata Safo.
(c)2015 Puvvada Wristband Club. All rights reserved.

The nm_matrix module is designed to reprensent any arbitary m-by-n matrix. It
knows it own number of rows and number of columns, and allows reading and writing
to specific addresses within its dimensonal bounds. It is effectively a RAM of
desired size.

===============================================================================
Specifications
===============================================================================

address size    (m_addr, n_addr):     7-bit
dimensions size (n_dim, m_dim):       7-bit
data size       (data_in, data_out):  32-bit
memory size     (matrix):             128-by-128 matrix

===============================================================================
Design
===============================================================================

The module allocates a full 32-bit 128-by-128 array to each matrix, but restricts
read and write access to array locations lower than its dimensions. That means
that it can be used to declare any 2D matrix at most 128-by-128. Matrices can also
be dynamically resized although that is not advised. On reset, it fills the entire
128-by-128 array with zeros, as initial values.

===============================================================================
Usage
===============================================================================

In order to use the module, one should first write to the matrix, before reading
from it. The testbench demonstrate a way of writing to the module from a flattened
array, before reading from it. With the transpose bit, there is an option to either
read requested values from the module, or its transposed values.
