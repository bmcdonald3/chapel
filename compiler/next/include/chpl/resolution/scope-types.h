/*
 * Copyright 2021 Hewlett Packard Enterprise Development LP
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

#ifndef CHPL_RESOLUTION_SCOPE_TYPES_H
#define CHPL_RESOLUTION_SCOPE_TYPES_H

#include "chpl/types/Type.h"
#include "chpl/uast/ASTNode.h"
#include "chpl/util/memory.h"

#include <unordered_map>
#include <utility>

namespace chpl {
namespace resolution {

// TODO: Should some/all of these structs be classes
// with getters etc? That would be appropriate for
// use as part of the library API.

/**
  Collects IDs with a particular name.
 */
struct OwnedIdsWithName {
  // If there is just one ID with this name, it is stored here,
  // and moreIds == nullptr.
  ID id;
  // If there is more than one, all are stored in here,
  // and id redundantly stores the first one.
  // This field is 'owned' in order to allow reuse of pointers to it.
  owned<std::vector<ID>> moreIds;

  OwnedIdsWithName(ID id)
    : id(std::move(id)), moreIds(nullptr)
  { }

  void appendId(ID newId) {
    if (moreIds.get() == nullptr) {
      // create the vector and add the single existing id to it
      moreIds = toOwned(new std::vector<ID>());
      moreIds->push_back(id);
    }
    // add the id passed
    moreIds->push_back(std::move(newId));
  }

  bool operator==(const OwnedIdsWithName& other) const {
    if (id != other.id)
      return false;

    if ((moreIds.get()==nullptr) != (other.moreIds.get()==nullptr))
      return false;

    if (moreIds.get()==nullptr && other.moreIds.get()==nullptr)
      return true;

    // otherwise check the vector elements
    return *moreIds.get() == *other.moreIds.get();
  }
  bool operator!=(const OwnedIdsWithName& other) const {
    return !(*this == other);
  }
};
struct BorrowedIdsWithName {
  // TODO: consider storing a variant of ID here
  // with symbolPath, postOrderId, and tag
  ID id;
  const std::vector<ID>* moreIds = nullptr;
  BorrowedIdsWithName() { }
  BorrowedIdsWithName(ID id) : id(std::move(id)) { }
  BorrowedIdsWithName(const OwnedIdsWithName& o)
    : id(o.id), moreIds(o.moreIds.get())
  { }
  bool operator==(const BorrowedIdsWithName& other) const {
    return id == other.id &&
           moreIds == other.moreIds;
  }
  bool operator!=(const BorrowedIdsWithName& other) const {
    return !(*this == other);
  }
  size_t hash() const {
    size_t ret = 0;
    if (moreIds == nullptr) {
      ret = hash_combine(ret, chpl::hash(id));
    } else {
      for (const ID& x : *moreIds) {
        ret = hash_combine(ret, chpl::hash(x));
      }
    }
    return ret;
  }

  const ID& firstId() const {
    if (moreIds == nullptr) {
      return id;
    } else {
      return (*moreIds)[0];
    }
  }
};

// DeclMap: key - string name,  value - vector of ID of a NamedDecl
// Using an ID here prevents needing to recompute the Scope
// if (say) something in the body of a Function changed
using DeclMap = std::unordered_map<UniqueString, OwnedIdsWithName>;

/**
  A scope roughly corresponds to a `{ }` block. Anywhere a new symbol could be
  defined / is defined is a scope.

  While generic instantiations generate something scope-like, the
  point-of-instantiation reasoning will need to be handled with a different
  type.
 */
struct Scope {
  const Scope* parentScope = nullptr;
  uast::asttags::ASTTag tag = uast::asttags::NUM_AST_TAGS;
  bool containsUseImport = false;
  bool containsFunctionDecls = false;
  ID id;
  UniqueString name;
  DeclMap declared;

  Scope() { }

  bool operator==(const Scope& other) const {
    return parentScope == other.parentScope &&
           tag == other.tag &&
           containsUseImport == other.containsUseImport &&
           containsFunctionDecls == other.containsFunctionDecls &&
           id == other.id &&
           declared == other.declared;
  }
  bool operator!=(const Scope& other) const {
    return !(*this == other);
  }
};

// This class supports both use and import
// It stores a normalized form of the symbols made available
// by a use/import clause.
struct VisibilitySymbols {
  ID symbolId;       // ID of the imported symbol, e.g. ID of a Module
  enum Kind {
    SYMBOL_ONLY,     // the named symbol itself only (one name in names)
    ALL_CONTENTS,    // (and names is empty)
    ONLY_CONTENTS,   // only the contents named in names
    CONTENTS_EXCEPT, // except the contents named in names (no renaming)
  };
  Kind kind = SYMBOL_ONLY;
  bool isPrivate = true;

  // the names/renames:
  //  pair.first is the name as declared
  //  pair.second is the name here
  std::vector<std::pair<UniqueString,UniqueString>> names;

  VisibilitySymbols() { }
  VisibilitySymbols(ID symbolId, Kind kind, bool isPrivate,
                    std::vector<std::pair<UniqueString,UniqueString>> names)
    : symbolId(symbolId), kind(kind), isPrivate(isPrivate),
      names(std::move(names))
  { }


  bool operator==(const VisibilitySymbols& other) const {
    return symbolId == other.symbolId &&
           kind == other.kind &&
           names == other.names;
  }
  bool operator!=(const VisibilitySymbols& other) const {
    return !(*this == other);
  }

  void swap(VisibilitySymbols& other) {
    symbolId.swap(other.symbolId);
    std::swap(kind, other.kind);
    names.swap(other.names);
  }
};

// Stores the result of in-order resolution of use/import
// statements. This would not be separate from resolving variables
// if the language design was that symbols available due to use/import
// are only available after that statement (and in that case this analysis
// could fold into the logic about variable declarations).
struct ResolvedVisibilityScope {
  const Scope* scope;
  std::vector<VisibilitySymbols> visibilityClauses;
  ResolvedVisibilityScope(const Scope* scope)
    : scope(scope)
  { }
  bool operator==(const ResolvedVisibilityScope& other) const {
    return scope == other.scope &&
           visibilityClauses == other.visibilityClauses;
  }
  bool operator!=(const ResolvedVisibilityScope& other) const {
    return !(*this == other);
  }
};

enum {
  LOOKUP_DECLS = 1,
  LOOKUP_IMPORT_AND_USE = 2,
  LOOKUP_PARENTS = 4,
  LOOKUP_TOPLEVEL = 8,
  LOOKUP_INNERMOST = 16,
};

using LookupConfig = unsigned int;

// When resolving a traditional generic, we also need to consider
// the point-of-instantiation scope as a place to find visible functions.
// This type tracks such a scope.
//
// PoiScopes do not need to consider scopes that are visible from
// the function declaration. These can be collapsed away.
//
// Performance: could have better reuse of PoiScope if it used the Scope ID
// rather than changing if the Scope contents do. But, the downside is that
// further queries would be required to compute which functions are
// visible. Which is better?
// If we want to make PoiScope not depend on the contents it might be nice
// to make Scope itself not depend on the contents, too.
struct PoiScope {
  const Scope* inScope = nullptr;         // parent Scope for the Call
  const PoiScope* inFnPoi = nullptr;      // what is the POI of this POI?

  bool operator==(const PoiScope& other) const {
    return inScope == other.inScope &&
           inFnPoi == other.inFnPoi;
  }
  bool operator!=(const PoiScope& other) const {
    return !(*this == other);
  }
};

struct InnermostMatch {
  typedef enum {
    ZERO = 0,
    ONE = 1,
    MANY = 2,
  } MatchesFound;

  ID id;
  MatchesFound found = ZERO;

  InnermostMatch() { }
  InnermostMatch(ID id, MatchesFound found)
    : id(id), found(found)
  { }
  bool operator==(const InnermostMatch& other) const {
    return id == other.id &&
           found == other.found;
  }
  bool operator!=(const InnermostMatch& other) const {
    return !(*this == other);
  }
  void swap(InnermostMatch& other) {
    id.swap(other.id);
    std::swap(found, other.found);
  }
};

} // end namespace resolution

/// \cond DO_NOT_DOCUMENT
template<> struct update<resolution::InnermostMatch> {
  bool operator()(resolution::InnermostMatch& keep,
                  resolution::InnermostMatch& addin) const {
    bool match = (keep == addin);
    if (match) {
      return false;
    } else {
      keep.swap(addin);
      return true;
    }
  }
};
/// \endcond

} // end namespace chpl

namespace std {

/// \cond DO_NOT_DOCUMENT
template<> struct hash<chpl::resolution::BorrowedIdsWithName>
{
  size_t operator()(const chpl::resolution::BorrowedIdsWithName& key) const {
    return key.hash();
  }
};
/// \endcond

} // end namespace std

#endif
