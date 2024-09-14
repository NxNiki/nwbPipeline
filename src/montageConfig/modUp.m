function n = modUp(n,modulus)
n = mod(n,modulus);
n(n==0) = modulus;
