/*
 * Copyright 2020-2023 Hewlett Packard Enterprise Development LP
 * Copyright 2004-2019 Cray Inc.
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* Provides a 'bigint' type and supporting math operations.

The ``bigint`` record supports arithmetic operations on arbitrary
precision integers in a manner that is broadly consistent with
the conventional operations on primitive fixed length integers.

The current implementation is based on the low-level types and
functions defined in the GMP module i.e. it is implemented using the
GNU Multiple Precision Integer Arithmetic library (GMP). More specifically
the record :record:`bigint` wraps the GMP type :type:`~GMP.mpz_t`.

The primary benefits of ``bigint`` over ``mpz_t`` are

  1) support for multi-locale programs

  2) the convenience of arithmetic operator overloads

  3) automatic memory management of GMP data structures

In addition to the expected set of operations, this record provides
a number of methods that wrap GMP functions in a natural way:

.. code-block:: chapel

 use BigInteger;

 var   a = new bigint(234958444);
 const b = new bigint("4847382292989382987395534934347");
 var   c = new bigint();

 writeln(a * b);

 c.fac(100);
 writeln(c);

Casting and declarations can be used to create ``bigint`` records as
well:

.. code-block:: chapel

 use BigInteger;

 var   a = 234958444: bigint;
 const b = "4847382292989382987395534934347": bigint;
 var   c: bigint;

.. warning::

  Creating a ``bigint`` from an integer literal that is larger than
  ``max(uint(64))`` would cause integer overflow before the
  ``bigint`` is created, and so results in a compile-time error.
  Strings should be used instead of integer literals for cases
  like this:

  .. code-block:: chapel

    // These would result in integer overflow and cause compile-time errors
    var bad1 = 4847382292989382987395534934347: bigint;
    var bad2 = new bigint(4847382292989382987395534934347);

    // These give the desired result
    var good1 = "4847382292989382987395534934347": bigint;
    var good2 = new bigint("4847382292989382987395534934347");


Wrapping an ``mpz_t`` in a ``bigint`` record may introduce a
measurable overhead in some cases.

The GMP library defines a low-level API that is based on
side-effecting compound operations.  The documentation recommends that
one prefer to reuse a small number of existing mpz_t structures rather
than using many values of short duration.

Matching this style using ``bigint`` records and the compound
assignment operators is likely to provide comparable performance to an
implementation based on ``mpz_t``.  So, for example:

.. code-block:: chapel

  x  = b
  x *= c;
  x += a;

is likely to achieve better performance than:

.. code-block:: chapel

  x = a + b * c;

The Chapel compiler currently introduces two short lived temporaries for the
intermediate results of the binary operators.

The operators on ``bigint`` include variations that accept Chapel
integers e.g.:

.. code-block:: chapel

  var a = new bigint("9738639463465935");
  var b = 9395739153 * a;

The Chapel int(64) literal is converted to an underlying,
platform-specific C integer, to invoke the underlying GMP primitive
function.  This example is likely to work well on popular 64-bit
platforms but to fail on common 32-bit platforms.  Runtime checks are
used to ensure the Chapel types can safely be cast to the
platform-specific types.  Ths program will halt if the Chapel value
cannot be represented using the GMP scalar type.

The checks are controlled by the compiler options ``--[no-]cast-checks``,
``--fast``, etc.

Casting from ``bigint`` to ``integral`` and ``real`` types is also
supported.  Values that are too large for the resultant type are
truncated.  GMP primitives are used to first cast to platform-specific C
types, which are then cast to Chapel types.  As a result, casting to
64-bit types on 32-bit platforms may result in additional truncation.
Additionally, casting a negative ``bigint`` to a ``uint`` will result in
the absolute value truncated to fit within the type.:

.. code-block:: chapel

  var a = new bigint(-1);
  writeln(a:uint);        // prints "1"

See :mod:`GMP` for more information on how to use GMP with Chapel.

*/

module BigInteger {
  use CTypes;
  use GMP;
  use HaltWrappers;
  use CTypes;
  use OS;


  /*
   Local copy of IO.EFORMAT as it is being phased out and is private in IO
   */
  private extern proc chpl_macro_int_EFORMAT():c_int;

  /*
    .. warning::

       The enum Round is deprecated, please use the enum round instead
  */
  deprecated "The enum Round is deprecated, please use the enum round instead"
  enum Round {
    DOWN = -1,
    ZERO =  0,
    UP   =  1
  }

  /* An enumeration of the different rounding strategies, for use with e.g.
     :proc:`~bigint.divQ` to determine how to round the quotient when performing
     the computation.

     - ``round.down`` indicates that the quotient should be rounded down towards
       -infinity and any remainder should have the same sign as the denominator.
     - ``round.zero`` indicates that the quotient should be rounded towards zero
       and any remainder should have the same sign as the numerator.
     - ``round.up`` indicates that the quotient should be rounded up towards
       +infinity and any remainder should have the opposite sign as the
       denominator.
   */
  enum round {
    down = -1,
    zero = 0,
    up = 1
  }

  pragma "ignore noinit"
  record bigint {
    // The underlying GMP C structure
    pragma "no doc"
    var mpz      : mpz_t;              // A dynamic-vector of C integers

    pragma "no doc"
    var localeId : chpl_nodeID_t;      // The locale id for the GMP state

    proc init() {
      this.complete();
      mpz_init(this.mpz);

      this.localeId = chpl_nodeID;
    }

    proc init(num: int) {
      this.complete();
      mpz_init_set_si(this.mpz, num.safeCast(c_long));

      this.localeId = chpl_nodeID;
    }

    // Within a given locale, bigint assignment creates a deep copy of the
    // data and so the record "owns" the GMP data.
    //
    // If a bigint is copied to a remote node then it will receive a shallow
    // copy.  The localeId points back the correct locale but the mpz field
    // is meaningless.
    pragma "no doc"
    proc deinit() {
      if _local || this.localeId == chpl_nodeID {
        mpz_clear(this.mpz);
      }
    }

    deprecated "bigint.size() is deprecated"
    proc size() : c_size_t {
      var ret: c_size_t;

      if _local {
        ret = mpz_size(this.mpz);

      } else if this.localeId == chpl_nodeID {
        ret = mpz_size(this.mpz);

      } else {
        const thisLoc = chpl_buildLocaleID(this.localeId, c_sublocid_any);

        on __primitive("chpl_on_locale_num", thisLoc) {
          ret = mpz_size(this.mpz);
        }
      }

      return ret;
    }

    proc writeThis(writer) throws {
      var s: string;

      if _local {
        s = this.get_str();

      } else if this.localeId == chpl_nodeID {
        s = this.get_str();

      } else {
        const thisLoc = chpl_buildLocaleID(this.localeId, c_sublocid_any);

        on __primitive("chpl_on_locale_num", thisLoc) {
          s = this.get_str();
        }
      }

      writer.write(s);
    }
  
    proc get_str(base: int = 10) : string {
      const base_ = base.safeCast(c_int);
      var   ret: string;

      if _local {
        var tmpvar = chpl_gmp_mpz_get_str(base_, this.mpz);

        try! {
          ret = createStringWithOwnedBuffer(tmpvar);
        }

      } else if this.localeId == chpl_nodeID {
        var tmpvar = chpl_gmp_mpz_get_str(base_, this.mpz);

        try! {
          ret = createStringWithOwnedBuffer(tmpvar);
        }

      } else {
        const thisLoc = chpl_buildLocaleID(this.localeId, c_sublocid_any);

        on __primitive("chpl_on_locale_num", thisLoc) {
          var tmpvar = chpl_gmp_mpz_get_str(base_, this.mpz);

          try! {
            ret = createStringWithOwnedBuffer(tmpvar);
          }
        }
      }

      return ret;
    }
  }
    
  //
  // Binary operators
  //

  // Addition
    operator bigint.+(const ref a: bigint, const ref b: bigint): bigint {
      var c = new bigint();

      if _local {
        mpz_add(c.mpz, a.mpz, b.mpz);

      } else if a.localeId == chpl_nodeID && b.localeId == chpl_nodeID {
        mpz_add(c.mpz, a.mpz, b.mpz);

      } else {
        const a_ = a;
        const b_ = b;

        mpz_add(c.mpz, a_.mpz, b_.mpz);
      }

      return c;
    }

    proc myAdd(const ref a: bigint, const ref b: bigint): bigint {
      var c = new bigint();

      if _local {
        mpz_add(c.mpz, a.mpz, b.mpz);

      } else if a.localeId == chpl_nodeID && b.localeId == chpl_nodeID {
        mpz_add(c.mpz, a.mpz, b.mpz);

      } else {
        const a_ = a;
        const b_ = b;

        mpz_add(c.mpz, a_.mpz, b_.mpz);
      }

      return c;
    }

  inline proc bigint.localize() : bigint {
    if _local || this.localeId == chpl_nodeID {
      return this;
    } else {
      const x:bigint = this; // assignment makes it local
      return x;
    }
  }
}
