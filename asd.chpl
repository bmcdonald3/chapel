module ArraySetopsMsg
{
    use Arkouda;

    proc intersect1dMsg(inArr1: [] ?t, inArr2: [] t) throws {
      return intersect1D(inArr1, inArr2);
    }
}


