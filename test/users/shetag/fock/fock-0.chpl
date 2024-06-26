config const natom = 5;
const n = (natom/2)*10 + ((natom+1)/2)*5;
// const bas_info : [{1..natom, 1..2}] int = [(i,j) in {1..natom, 1..2}] 5*(i/2) + 10*((i-1)/2) + if (j==1) then 1 else 10/(i%2+1);
const bas_info : [{1..natom, 1..2}] int = [(i,j) in {1..natom, 1..2}] bas_init(i,j);

proc bas_init(i,j) {
  return 5*(i/2) + 10*((i-1)/2) + if (j==1) then 1 else 10/(i%2+1);
}

type elemType = real(64);
const matD : domain(2) = {1..n, 1..n}; 
const dmat : [matD] elemType = [(i,j) in matD] 1.0/(i+j); 
var jmat2, kmat2, jmat2T, kmat2T : [matD] elemType; 
var oneAtATime: sync bool = true;

class blockIndices {
  const ilo, ihi, jlo, jhi, klo, khi, llo, lhi : int;
}

proc buildjk() {
  for bI in gen() do // sjd: changed forall to for
    buildjk_atom4(bI);
  
  cobegin with (ref jmat2T, ref kmat2T) {
    [(i,j) in matD with (ref jmat2T)] jmat2T(i,j) = jmat2(j,i);
    [(i,j) in matD with (ref kmat2T)] kmat2T(i,j) = kmat2(j,i);
  }

  cobegin with (ref jmat2, ref kmat2) {
    jmat2 = (jmat2 + jmat2T) * 2;
    kmat2 += kmat2T;
  }
  
  writeln("\n1st row of coulomb matrix:-\n", jmat2(1..1,1..n));
  writeln("\n1st col of coulomb matrix:-\n", jmat2(1..n,1..1));
  writeln("\n1st row of exchange matrix:-\n", kmat2(1..1,1..n));
  writeln("\n1st col of exchange matrix:-\n", kmat2(1..n,1..1));
}

iter gen() {
  for iat in 1..natom { // sjd: changed forall to for because of yield
    for jat in 1..iat { // sjd: changed forall to for because of yield
      for kat in 1..iat { // sjd: changed forall to for because of yield
        const lattop = if (kat==iat) then jat else kat;
        for lat in 1..lattop { // sjd: changed forall to for because of yield
          // on/Locales not supported yet.
          yield new unmanaged blockIndices(bas_info(iat,1), bas_info(iat,2), bas_info(jat,1), bas_info(jat,2), bas_info(kat,1), bas_info(kat,2), bas_info(lat,1), bas_info(lat,2));
        }
      }
    }
  }
}

proc buildjk_atom4(bI) {
  const (ilo,ihi,jlo,jhi,klo,khi,llo,lhi) = (bI.ilo,bI.ihi,bI.jlo,bI.jhi,bI.klo,bI.khi,bI.llo,bI.lhi);
  
  const (ijD,ikD,ilD,jkD,jlD,klD) = ({ilo..ihi,jlo..jhi},{ilo..ihi,klo..khi},{ilo..ihi,llo..lhi},{jlo..jhi,klo..khi},{jlo..jhi,llo..lhi},{klo..khi,llo..lhi});
  
  const dij = dmat(ijD);
  const dik = dmat(ikD);
  const dil = dmat(ilD);
  const djk = dmat(jkD);
  const djl = dmat(jlD);
  const dkl = dmat(klD);
  
  var jij : [ijD] elemType;
  var jkl : [klD] elemType;
  var kik : [ikD] elemType;
  var kil : [ilD] elemType;
  var kjk : [jkD] elemType;
  var kjl : [jlD] elemType;
  
  var jtop, ktop, ltop : int;
  var facij, facijkl, gijkl: elemType;
  
  for i in ilo..ihi {
    if (ilo==jlo) then jtop = i; else jtop = jhi;
    for j in jlo..jtop {
      if (i==j) then facij = 0.5; else facij = 1.0;
      if (ilo==klo && jlo==llo) then ktop = i; else ktop = khi;
      for k in klo..ktop {
        ltop = lhi;
        if (klo==llo) then ltop = k;
        if (ilo==klo && jlo==llo && k==i) then ltop = j;
        for l in llo..ltop {
          facijkl = facij;
          if (k==l) then facijkl *= 0.5;
          if (i==k && j==l) then facijkl *= 0.5;
          gijkl = g(i,j,k,l)*facijkl;
          jij(i,j) += dkl(k,l)*gijkl;
          jkl(k,l) += dij(i,j)*gijkl;
          kik(i,k) += djl(j,l)*gijkl;
          kil(i,l) += djk(j,k)*gijkl;
          kjk(j,k) += dil(i,l)*gijkl;
          kjl(j,l) += dik(i,k)*gijkl;
        }
      }
    }
  }
  
  var tmp = oneAtATime.readFE();
  jmat2(ijD) += jij;
  jmat2(klD) += jkl;
  kmat2(ikD) += kik;
  kmat2(ilD) += kil;
  kmat2(jkD) += kjk;
  kmat2(jlD) += kjl;
  oneAtATime.writeEF(tmp);	

  delete bI;
}

proc g(i,j,k,l) {
  return 1.0/(i*j + k*l);
}

proc main() {
  buildjk();
}
