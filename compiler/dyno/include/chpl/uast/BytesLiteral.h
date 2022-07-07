/*
 * Copyright 2021-2022 Hewlett Packard Enterprise Development LP
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

#ifndef CHPL_UAST_BYTESLITERAL_H
#define CHPL_UAST_BYTESLITERAL_H

#include "chpl/framework/Location.h"
#include "chpl/uast/Literal.h"
#include "chpl/uast/StringLikeLiteral.h"

namespace chpl {
namespace uast {


/**
  This class represents a bytes literal, for example `b"hello"`
  and `b''' bytes contents here '''`.
 */
class BytesLiteral final : public StringLikeLiteral {
 private:
  BytesLiteral(const types::StringParam* value,
               StringLikeLiteral::QuoteStyle quotes)
    : StringLikeLiteral(asttags::BytesLiteral, value, quotes)
  { }

  // contentsMatchInner / markUniqueStringsInner are in StringLikeLiteral
  // and would need to be defined here if any fields are added.

 public:
  ~BytesLiteral() override = default;

  static owned<BytesLiteral> build(Builder* builder, Location loc,
                                   const std::string& value,
                                   StringLikeLiteral::QuoteStyle quotes);

  /**
    Returns the value of this bytes literal as a UniqueString
    which does not include the quotes.
   */
  UniqueString str() const {
    assert(value_->isStringParam());
    const types::StringParam* p = (const types::StringParam*) value_;
    return p->value();
  }
};


} // end namespace uast
} // end namespace chpl

#endif
