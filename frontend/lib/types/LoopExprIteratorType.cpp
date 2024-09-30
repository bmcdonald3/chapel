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

#include "chpl/types/LoopExprIteratorType.h"
#include "chpl/framework/query-impl.h"

namespace chpl {
namespace types {

const owned<LoopExprIteratorType>&
LoopExprIteratorType::getLoopExprIteratorType(Context* context,
                                              QualifiedType yieldType,
                                              bool isZippered,
                                              bool supportsParallel,
                                              QualifiedType iterand,
                                              ID sourceLocation) {
  QUERY_BEGIN(getLoopExprIteratorType, context, yieldType, isZippered, supportsParallel, iterand, sourceLocation);
  auto result = toOwned(new LoopExprIteratorType(std::move(yieldType), isZippered, supportsParallel, std::move(iterand), std::move(sourceLocation)));
  return QUERY_END(result);
}

const LoopExprIteratorType*
LoopExprIteratorType::get(Context* context,
                          QualifiedType yieldType,
                          bool isZippered,
                          bool supportsParallel,
                          QualifiedType iterand,
                          ID sourceLocation) {
  return getLoopExprIteratorType(context, std::move(yieldType), isZippered, supportsParallel, std::move(iterand), std::move(sourceLocation)).get();
}

}  // end namespace types
}  // end namespace chpl
