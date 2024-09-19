/*
 * Copyright 2024 Hewlett Packard Enterprise Development LP
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

#ifndef CHPL_TYPES_LOOP_EXPR_ITERATOR_TYPE_H
#define CHPL_TYPES_LOOP_EXPR_ITERATOR_TYPE_H

#include "chpl/types/Type.h"
#include "chpl/types/QualifiedType.h"
#include "chpl/types/IteratorType.h"

namespace chpl {
namespace types {

class LoopExprIteratorType final : public IteratorType {
 private:
  bool isZippered_;
  QualifiedType iterand_;
  ID sourceLocation_;

  LoopExprIteratorType(bool isZippered,
                       QualifiedType iterand,
                       ID sourceLocation,
                       QualifiedType yieldType)
    : IteratorType(typetags::LoopExprIteratorType, std::move(yieldType)),
      isZippered_(isZippered), iterand_(std::move(iterand)),
      sourceLocation_(std::move(sourceLocation)) {
    if (isZippered_) {
      CHPL_ASSERT(iterand_.type() && iterand_.type()->isTupleType());
    }
  }

  bool contentsMatchInner(const Type* other) const {
    auto rhs = (LoopExprIteratorType*) other;
    return yieldType_ == rhs->yieldType_ &&
           isZippered_ == rhs->isZippered_ &&
           iterand_ == rhs->iterand_ &&
           sourceLocation_ == rhs->sourceLocation_;
  }

  void markUniqueStringsInner(Context* context) const {
    yieldType_.mark(context);
    iterand_.mark(context);
    sourceLocation_.mark(context);
  }

  static const owned<LoopExprIteratorType>&
  getLoopExprIteratorType(Context* context,
                          bool isZippered,
                          QualifiedType iterand,
                          ID sourceLocation,
                          QualifiedType yieldType);

 public:
  static const LoopExprIteratorType* get(Context* context,
                                         bool isZippered,
                                         QualifiedType iterand,
                                         ID sourceLocation,
                                         QualifiedType yieldType);

  bool isZippered() const {
    return isZippered_;
  }

  const ID& sourceLocation() const {
    return sourceLocation_;
  }

  const QualifiedType& iterand() const {
    return iterand_;
  }
};

} // end namespace types
} // end namespace chpl

#endif
